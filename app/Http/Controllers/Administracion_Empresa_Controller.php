<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
//Extras
use DB;
use \Firebase\JWT\JWT;
use Config;
use GuzzleHttp\Client;
// Funciones
use App\libs\Funciones;

class Administracion_Empresa_Controller extends Controller
{
    public function __construct(Request $request)

        {
        $key=config('jwt.secret');
        $decoded = JWT::decode($request->token, $key, array('HS256'));
        $this->user=$decoded;
        $this->name_bdd=$this->user->nbdb;
        // Extras
      $this->client=new Client();
        }

    public function Get_Datos_Empresa(Request $request)

        {
            $resultado = DB::connection($this->name_bdd)->table('usuarios')->where('id', '=', $this->user->sub)->first();
            return response()->json(["respuesta" => $resultado->estado_clave], 200);
        }

        public function Get_Establecimientos(Request $request)

        {
            $ruc=$this->user->ruc.'001';
       $resultado=DB::connection('nextbookconex')->select("SELECT administracion.empresa_ruc('".$ruc."')");
       return response()->json(["respuesta" =>$resultado], 200);
      // $resultado = $this->tableEmpresas->select('ruc')->where('ruc', '=', $request->input('ruc'))->get();
    if (count($resultado)==0)
      {
      $res = $this->client->request('GET', config('global.appserviciosnext').'/public/getDatos', ['json' => ['tipodocumento' => 'RUC', 'nrodocumento' => $ruc]]);
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
      return response()->json(["respuesta" => $respuesta['establecimientos']], 200);
      }else{
        return response()->json(["respuesta" => 'false-sri',"error"=>'no-registro-SRI'], 200);
      }
      }
      else
      {
          return response()->json(["respuesta" =>$resultado], 200);
      }
      
        }

        public function Update_Password(Request $request)
        {
            $resultado = DB::connection($this->name_bdd)->statement("SELECT * FROM actualiza_clave('".$this->user->sub."','".bcrypt($request->pass)."')");
        if ($resultado)
            {
            return response()->json(["respuesta" => true], 200);
            }
          else return response()->json(["respuesta" => false], 200);
        }

}
