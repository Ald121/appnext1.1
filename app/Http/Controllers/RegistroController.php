<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Requests;
// Modelos
use App\empresas;
// Funciones
use App\libs\Funciones;
// Extras
use Carbon\Carbon;
use Mail;
use GuzzleHttp\Client;
use DB;
//-------------------------  autenticacion -------
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class RegistroController extends Controller
{
    public function __construct(){
    	// Modelos
    	$this->empresas=new empresas();
    	// Funciones
    	$this->funciones=new Funciones();
      // Extras
      $this->client=new Client();
      // Autenticacion
      // $this->user = JWTAuth::parseToken()->authenticate();
    }

    public function Buscar_Informacion_Ruc(Request $request){
      $resultado=DB::connection('nextbookconex')->select("SELECT * FROM empresa_ruc('".$request->input('ruc')."')");
      // $resultado = $this->tableEmpresas->select('ruc')->where('ruc', '=', $request->input('ruc'))->get();
    if (count($resultado)==0)
      {
      $res = $this->client->request('GET', config('global.appserviciosnext').'/public/getDatos', ['json' => ['tipodocumento' => 'RUC', 'nrodocumento' => $request->input('ruc') ]]);
      $respuesta = json_decode($res->getBody()->getContents() , true);
      if ($respuesta['datosEmpresa']['valid']!='false') {
      $modifiedString = str_replace('&nbsp;', null,$respuesta['datosEmpresa']['fecha_inicio_actividades']);
      $respuesta['datosEmpresa']['fecha_inicio_actividades']=$modifiedString;

      $modifiedString = str_replace('&nbsp;', null, $respuesta['datosEmpresa']['fecha_reinicio_actividades']);
      $respuesta['datosEmpresa']['fecha_reinicio_actividades']=$modifiedString;

      $modifiedString =str_replace('&nbsp;', null, $respuesta['datosEmpresa']['fecha_actualizacion']);
      $respuesta['datosEmpresa']['fecha_actualizacion']=$modifiedString;

      DB::connection('infoconex')->table('empresas')
            ->where('ruc', $request->input('ruc'))
                                  ->update(array( 
                                              'razon_social'=>$respuesta['datosEmpresa']['razon_social'],
                                              'nombre_comercial'=>$respuesta['datosEmpresa']['nombre_comercial'],
                                              'estado_contribuyente'=>$respuesta['datosEmpresa']['estado_contribuyente'],
                                              'clase_contribuyente'=>$respuesta['datosEmpresa']['clase_contribuyente'],
                                              'tipo_contribuyente'=>$respuesta['datosEmpresa']['tipo_contribuyente'],
                                              'obligado_llevar_contabilidad'=>$respuesta['datosEmpresa']['obligado_llevar_contabilidad'],
                                              'actividad_economica'=>$respuesta['datosEmpresa']['actividad_economica'],
                                              // 'fecha_inicio_actividades'=>$respuesta['datosEmpresa']['fecha_inicio_actividades'],
                                              // 'fecha_cese_actividades'=>$respuesta['datosEmpresa']['fecha_cese_actividades'],
                                              // 'fecha_reinicio_actividades'=>$respuesta['datosEmpresa']['fecha_reinicio_actividades']
                                              // 'fecha_actualizacion'=>$respuesta['datosEmpresa']['fecha_actualizacion']
                                              ));
      return response()->json(["respuesta" => $respuesta], 200);
      }else{
        return response()->json(["respuesta" => 'false-sri',"error"=>'no-registro-SRI'], 200);
      }
      }
      else
      {
        $sql=DB::connection('nextbookconex')->select("SELECT ruc_ci FROM empresas WHERE ruc_ci='".$request->input('ruc')."'");
        if (count($sql)==0) {
            return response()->json(["respuesta" =>$resultado[0]], 200);
        }else{
          return response()->json(["respuesta" =>false,"error"=>'registro-existente'], 200);
        }
      }
    }

    public function Save_Datos_Ruc(Request $request){
      $ruc_ci=$request->input('ruc');
      $nick=substr(str_replace(' ', '_', $request->input('razon_social')),0,24).'_'.$request->input('ruc');
      // $nick=strlen($nick);
      $this->empresas->id=$this->funciones->generarID(); 
      $this->empresas->razon_social=$request->input('razon_social'); 
      $this->empresas->actividad_economica=$request->input('actividad_economica'); 
      $this->empresas->ruc_ci=$ruc_ci; 
      $this->empresas->estdo_contribuyente=$request->input('estdo_contribuyente'); 
      $this->empresas->fecha_inicio_actividades=$request->input('fecha_inicio_actividades'); 
      $this->empresas->nombre_comercial=$request->input('nombre_comercial'); 
      $this->empresas->obligado_lleva_contabilida=$request->input('obligado_lleva_contabilida'); 
      $this->empresas->tipo_contribuyente=$request->input('tipo_contribuyente'); 
      $this->empresas->id_estado='P';
      $this->empresas->nick=$nick;
      $this->empresas->fecha_creacion=Carbon::now()->toDateString();
    	$save=$this->empresas->save();

      $data = [ "correo"=>$request->input('correo'),
                "codigo"=>$ruc_ci,
                'razon_social'=>$request->input('razon_social'),
                'telefono'=>$request->input('telefono'),
                'telefono1'=>$request->input('telefono1'),
                'provincia'=>$request->input('provincia'),
                'celular'=>$request->input('celular')
                ];
      $this->enviar_correo_registro($data);
    	// if ($save) {
    		return response()->json(['respuesta'=>true],200);
    	// }
    }

    public function enviar_correo_registro($data){
        $correo_enviar=$data['correo'];
        $razon_social=$data['razon_social'];
    Mail::send('email_registro', $data, function($message)use ($correo_enviar,$razon_social)
            {
                $message->from("registro@oyefm.com",'Nextbook');
                $message->to($correo_enviar,$razon_social)->subject('Verifica tu cuenta');
            });
    }

    
    public function enviar_correo_credenciales($data){
        $correo_enviar=$data['correo'];
        $razon_social=$data['razon_social'];
    Mail::send('credenciales_ingreso', $data, function($message)use ($correo_enviar,$razon_social)
            {
                $message->from("registro@oyefm.com",'Nextbook');
                $message->to($correo_enviar,$razon_social)->subject('Credenciales de Ingreso');
            });
    }

    public function Activar_Cuenta(Request $request){
      $resultado=$this->empresas->select('razon_social')->where('id_estado','P')->where('ruc_ci',$request->input('ruc'))->get();
      if (count($resultado)!=0) {
        $data['correo']=$request->input('correo');
      $data['razon_social']=$resultado[0]['razon_social'];
      $data['nombre_comercial']=$resultado[0]['razon_social'];
      $data['user_nextbook']=$request->input('ruc').'@facturanext.com';
      $data['pass_nextbook']=$request->input('ruc');
      $resultado=$this->empresas->where('ruc_ci',$request->input('ruc'))->first();
      $name=$resultado->nick;
      $create=DB::connection('infoconex')->statement("CREATE DATABASE $name OWNER $name ");
      if ($create) {
        $update=DB::connection('usuarioconex')->table('usuarios')
            ->where('id', $request->input('ruc'))
                                  ->update(array('id_estado' => 'A','clave_clave'=>bcrypt($request->input('ruc'))));
        $update=$this->empresas->where('ruc_ci',$request->input('ruc'))->update(['id_estado' => 'A']);
                                  if ($update) {
                                    $this->enviar_correo_credenciales($data);
                                    return response()->json(["respuesta"=>true]);
                                  }
      }
    }else return response()->json(["respuesta"=>false]);
      
    }

    public function Get_Provincias(Request $request){

      $resultado=DB::connection('localidadesconex')->select("SELECT nombre,id,codigo_telefonico FROM view_localidades WHERE id_padre='00' ORDER BY nombre ASC");
      return response()->json(["respuesta" => $resultado], 200);
    }
}
