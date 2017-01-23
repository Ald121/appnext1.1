<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Requests;
// Modelos
use App\empresas;
use App\Usuarios;
// Funciones
use App\libs\Funciones;
// Extras
use Carbon\Carbon;
use Mail;
use GuzzleHttp\Client;
use DB;
use Config;
use App\libs\xmlapi;
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
      return response()->json(["respuesta" => $respuesta['datosEmpresa']], 200);
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

      //return response()->json(['respuesta'=>$request->all()]);
      $ruc_ci=$request->input('ruc');
      $nick=substr(str_replace(' ', '_', $request->input('razon_social')),0,11).'_'.$request->input('ruc');
      //echo strlen($nick);
      $this->empresas->id=$this->funciones->generarID(); 
      $this->empresas->razon_social=$request->input('razon_social'); 
      $this->empresas->actividad_economica=$request->input('actividad_economica'); 
      $this->empresas->ruc_ci=$ruc_ci; 
      $this->empresas->estado_contribuyente=$request->input('estado_contribuyente'); 
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

    public function consultar_SRI($ruc){
      $res = $this->client->request('GET', config('global.appserviciosnext').'/public/getDatos', ['json' => ['tipodocumento' => 'RUC', 'nrodocumento' => $ruc ]]);
      $respuesta = json_decode($res->getBody()->getContents() , true);
      if ($respuesta['datosEmpresa']['valid']!='false') {
      $modifiedString = str_replace('&nbsp;', null,$respuesta['datosEmpresa']['fecha_inicio_actividades']);
      $respuesta['datosEmpresa']['fecha_inicio_actividades']=$modifiedString;

      $modifiedString = str_replace('&nbsp;', null, $respuesta['datosEmpresa']['fecha_reinicio_actividades']);
      $respuesta['datosEmpresa']['fecha_reinicio_actividades']=$modifiedString;

      $modifiedString =str_replace('&nbsp;', null, $respuesta['datosEmpresa']['fecha_actualizacion']);
      $respuesta['datosEmpresa']['fecha_actualizacion']=$modifiedString;

      return $respuesta;
    }
  }

    public function Activar_Cuenta(Request $request){
      $resultado=$this->empresas->select('razon_social','actividad_economica')->where('id_estado','P')->where('ruc_ci',$request->input('ruc'))->get();
      if (count($resultado)!=0) {
      $data['correo']=$request->input('correo');
      $data['razon_social']=$resultado[0]['razon_social'];
      $data['nombre_comercial']=$resultado[0]['razon_social'];
      $data['user_nextbook']=$request->input('ruc').config('global.dominio');
      $actividad_economica=$resultado[0]['actividad_economica'];
      $resultado=$this->empresas->where('ruc_ci',$request->input('ruc'))->first();
      $name=strtolower(substr(str_replace(' ', '_', $resultado['razon_social']),0,11).'_'.$request->input('ruc'));
      //$pass_user=$data['pass_nextbook'];
      DB::connection('nextbookconex')->statement("SELECT * from crea_usuario('".$name."','".$request->input('ruc')."') ");
      $create=DB::connection('infoconex')->statement("CREATE DATABASE $name OWNER $name ");
      if ($create) {
        exec("PGPASSWORD=rootdow psql -U postgres -d ".$name." -p 5432 -h localhost < /var/www/html/appnext1.1/postgres/basico.sql", $cmdout, $cmdresult );
        $pass_email=$this->funciones->generarPass();
        $pass_next=$this->funciones->generarPass();
        $update=DB::connection('usuarioconex')->table('usuarios')
            ->where('id', $request->input('ruc'))
                                  ->update(array('id_estado' => 'A','clave_clave'=>bcrypt($request->input('ruc')),'mail'=>$request->input('ruc').'@oyefm.com','clave_mail'=>$pass_email));
        $update=$this->empresas->where('ruc_ci',$request->input('ruc'))->update(['id_estado' => 'A','correo_institucional'=>$request->input('ruc').'@'.config('global.dominio'),'clave_correo_institucional'=>$pass_email]);
        if ($update) {
          //Crear Email
          $this->crear_email($request->input('ruc'),$pass_email);
          Config::set('database.connections.'.$name, array(
                'driver' => 'pgsql',
                'host' => 'localhost',
                'port' =>  '5432',
                'database' =>  $name,
                'username' =>  $name,
                'password' =>  $request->input('ruc'),
                'charset' => 'utf8',
                'prefix' => '',
                'schema' => 'usuarios',
                'sslmode' => 'prefer',
        ));
          ///CREAR USUARIO
        $id=$this->funciones->generarID();
        $data['pass_nextbook']=$pass_next;
        $usuarios=new Usuarios(); 
        $usuarios->changeConnection($name);
        $usuarios->id=$id;
        $usuarios->nick='admin'.config('global.dominio');
        $usuarios->clave_clave=bcrypt($pass_next);
        $usuarios->id_estado='A';
        $usuarios->estado_clave=FALSE;
        $usuarios->id_tipo_usuario=1;
        $usuarios->fecha_creacion=Carbon::now()->toDateString();
        $usuarios->save();
        //ID DE USUARIO
        $id_usuario=$usuarios->id;

        $datos=$this->consultar_SRI($request->input('ruc'));
        $sucursales=$datos['establecimientos']['sucursal'];
        $responsable=$datos['establecimientos']['adicional'];
        //Registrar Empresa
        $resultado=DB::connection($name)->table('administracion.empresas')->insert([
           'razon_social'=>$data['razon_social'],
           'actividad_economica'=>$actividad_economica,
           'ruc_ci'=>$request->input('ruc'),
           'nombre_comercial'=>$data['nombre_comercial'],
           'id_estado'=>'A',
           'fecha'=>Carbon::now()->toDateString()
          ]);
        //GET Sucursales SRI
        $datos=$this->consultar_SRI($request->input('ruc'));
        $resultado=DB::connection('nextbookconex')->select("SELECT * FROM empresa_ruc('".$request->input('ruc')."') LIMIT 1");
        if (count($resultado)==0) {
          $resultado=$datos['establecimientos']['sucursal'];
          $nombre_localidad=explode('/', $resultado[0]['direccion']);
          $nombre_localidad=str_replace(' ', '', $nombre_localidad[1]);
          $calle=str_replace(' ', '', $nombre_localidad[2]);
        }else{
          $nombre_localidad=$resultado[0]->descripcion_canton;
          $calle=$resultado[0]->calle;
        }

        $localizacion=DB::connection('nextbookconex')->select("SELECT id FROM public.view_localidades WHERE nombre= '".$nombre_localidad."'");
        $datos_repesentante=explode(' ', $responsable['representante_legal']);
          //Registrar Persona
          DB::connection($name)->table('public.personas')->insert(
          [
          'primer_nombre'=>$datos_repesentante[2],
           'segundo_nombre'=>$datos_repesentante[3],
           'primer_apellido'=>$datos_repesentante[0],
           'segundo_apellido'=>$datos_repesentante[1],
           'id_localidad'=>$localizacion[0]->id,
           'calle'=>$calle,
           'transversal'=>null,
           'numero'=>null
          ]);
          $id_persona=DB::connection($name)->table('public.personas')->select('id')->where('primer_nombre',$datos_repesentante[2])->first();
          // Guardar Documento
          $actual_date=Carbon::now()->setTimezone('America/Guayaquil')->toDateTimeString();
          DB::connection($name)->table('public.personas_documentos_identificacion')->insert(
          [
          'id_persona'=>$id_persona->id,
           'id_tipo_documento'=>1,
           'numero_identificacion'=>$responsable['cedula'],
           'estado'=>'A',
           'fecha'=>$actual_date
          ]);
          //Guardar Correo
          $actual_date=Carbon::now()->setTimezone('America/Guayaquil')->toDateTimeString();
          DB::connection($name)->table('public.personas_correo_electronico')->insert(
          [
          'id_persona'=>$id_persona->id,
           'correo_electronico'=>$request->input('correo'),
           'estado'=>'A',
           'fecha'=>$actual_date
          ]);
          //Guardar Telefono
          $array_telefono=['telefono'=>$request->input('telefono'),'telefono'=>$request->input('telefono1')];
          //Guardar Empleado
          DB::connection($this->name_bdd)->table('talento_humano.empleados')->insert(
          [
          'id_persona'=>$id_persona->id,
          'id_usuario'=>$id_usuario,
          'estado'=>'A'
          ]);

          foreach ($array_telefono as $key => $value) {
            $actual_date=Carbon::now()->setTimezone('America/Guayaquil')->toDateTimeString();
            DB::connection($name)->table('public.telefonos_personas')->insert(
            [
            'id_persona'=>$id_persona->id,
             'numero'=>$value,
             'estado'=>'A',
             'fecha'=>$actual_date,
             'id_operadora_telefonica'=>1
            ]);
          }

        //Registrar Sucursales
        //$id_persona=DB::connection($name)->table('public.personas')->select('id')->where('ci_documento',$responsable['cedula'])->first();
        foreach ($sucursales as $key => $value) {
          $localizacion_array=explode('/', $value['direccion']);
          $localizacion=DB::connection('nextbookconex')->select("SELECT id FROM public.view_localidades WHERE nombre= '".str_replace(' ', '', $localizacion_array[1])."'");
          
          //if (count($localizacion)==0) {
            $localizacion='00';
          /*}else{
            $localizacion=$localizacion[0]->id;
          }*/
          $localizacion_sucursal=["direccion"=>$localizacion_array[0].'/'.$localizacion_array[1].'/'.$localizacion_array[2]];
          $datos_empresariales=['telefono'=>$request->telefono,'telefono1'=>$request->telefono1,'correo'=>$request->correo,'celular'=>$request->celular];
          DB::connection($name)->table('administracion.sucursales')->insert([
          'nombre'=>$value['nombre_sucursal'],
          'responsable'=>$id_persona->id,
          'datos_empresariales'=>json_encode($datos_empresariales),
          'localizacion_sucursal'=>json_encode($localizacion_sucursal),
          'codigo_sri'=>$value['codigo']
          ]);
        }
          $this->enviar_correo_credenciales($data);
          return response()->json(["respuesta"=>true]);
        }
      }
    }
    else return response()->json(["respuesta"=>false]);
      
    }

    private function crear_email($user,$email_pass)
    {
        $ip           = config('global.dominio'); 
        $account      = "oyefm"; 
        $passwd       = "FRf74G7oW,$0yTQ"; 
        $port         = 2083; 
        $email_domain = config('global.dominio'); 
        $email_quota  = 50; 
        $xmlapi       = new xmlapi($ip);
        $xmlapi->set_port($port); 
        $xmlapi->password_auth($account, $passwd); 
        // $email_pass = "356497";
        $result        = "";
        if (!empty($user)){
            while (true) {

                $call   = array(
                    'domain' => $email_domain,
                    'email' => $user,
                    'password' => $email_pass,
                    'quota' => $email_quota
                );

                $call_f = array(
                    'domain' => $email_domain,
                    'email' => $user,
                    'fwdopt' => "fwd",
                    'fwdemail' => ""
                );
                $xmlapi->set_debug(0); 
                
                $result         = $xmlapi->api2_query($account, "Email", "addpop", $call);
                $result_forward = $xmlapi->api2_query($account, "Email", "addforward", $call_f); 

                
                if ($result->data->result == 1) {
                    $result = $user.'@'.$email_domain;
                    if ($result_forward->data->result == 1) {
                        $result = $user . '@' . $email_domain . ' forward to ' . $dest_email;
                    }
                } else {
                    $result = $result->data->reason;
                    break;
                }
                break;
            }
            }
        return $result;
        
    }

    public function Get_Provincias(Request $request){

      $resultado=DB::connection('localidadesconex')->select("SELECT nombre,id,codigo_telefonico FROM view_localidades WHERE id_padre='00' ORDER BY nombre ASC");
      return response()->json(["respuesta" => $resultado], 200);
    }
    public function Get_Ciudades(Request $request){

      $resultado=DB::connection('localidadesconex')->select("SELECT nombre,id,codigo_telefonico FROM view_localidades WHERE length(id_padre)=2 and nombre!='ECUADOR' ORDER BY nombre ASC");
      return response()->json(["respuesta" => $resultado], 200);
    }
}
