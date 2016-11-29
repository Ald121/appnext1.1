<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Requests;
// Modelos
use App\empresas;
use App\Usuarios;
use App\ingresos_usuarios;
//-------------------------------------- Autenticacion ---------------
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
// Funciones
use App\libs\Funciones;
// Extras
use Carbon\Carbon;
use Mail;
use GuzzleHttp\Client;
use DB;
use Config;
use Auth;
use Hash;

class loginController extends Controller
{
    public function __construct(){
    	// Modelos
    	$this->usuarios=new Usuarios();
        $this->ingresos_usuarios=new ingresos_usuarios();
        $this->empresas=new empresas();
    }

    public function Acceso(Request $request){
        $acceso=json_decode($request->acceso);
        // $credentials = ['nick' => $request->nick, 'password' => $request->clave_clave];

        $datos=$this->usuarios->select('nick','id')->where('id',$acceso->nick.'001')->get();
        if (count($datos)==0) {
            return response()->json(["respuesta"=>false]);
        }

        $name_bdd = $datos[0]['nick'];

        $name_bdd=strtolower($datos[0]['nick']);
        $pass_bdd=$datos[0]['id'];

        Config::set('database.connections.'.$name_bdd, array(
                'driver' => 'pgsql',
                'host' => 'localhost',
                'port' =>  '5432',
                'database' =>  $name_bdd,
                'username' =>  $name_bdd,
                'password' =>  $pass_bdd,
                'charset' => 'utf8',
                'prefix' => '',
                'schema' => 'usuarios',
                'sslmode' => 'prefer',
        ));
        $usuarios=new Usuarios(); 
        $usuarios->changeConnection($name_bdd);
        $user=$acceso->nick.'001@facturanext.com';

        $json['ip_cliente']=$request->input('ip_cliente');
        $json['macadress']=$request->input('macadress');
        $this->ingresos_usuarios->usuario=$request->input('acceso');
        $this->ingresos_usuarios->ip_acceso=json_encode($json);
        $this->ingresos_usuarios->informacion_servidor=$request->input('info_servidor');
        $this->ingresos_usuarios->fecha=Carbon::now()->toDateString();
        $this->ingresos_usuarios->save();

        $datos=$usuarios->select('clave_clave')->where('nick',$user)->first();
        $checkpass=Hash::check($acceso->clave, $datos['clave_clave']);

        if ($checkpass) {
         $datos = $usuarios->select('id','nick')->where('nick',$user)->first();
         $extra=['nbdb'=>$name_bdd,'pnb'=>$pass_bdd,'ruc'=>$acceso->nick];
         $token = JWTAuth::fromUser($datos,$extra);
         $datosE=DB::connection('nextbookconex')->table('empresas')->select('id',
            'razon_social',
            'actividad_economica',
            'ruc_ci',
            'estado_contribuyente',
            'fecha_inicio_actividades',
            'nombre_comercial',
            'obligado_lleva_contabilida',
            'tipo_contribuyente',
            'fecha_creacion')->where('id_estado','A')->where('ruc_ci',$acceso->nick.'001')->first();

         //$usuarios->where('nick',$user)->update(["token"=>$token]);
         return response()->json(['respuesta'=>true,'token'=>$token,'datosE'=>$datosE]);
        }
        return response()->json(["respuesta"=>$checkpass]);
        //return response()->json(["respuesta"=>$name_bdd]);
           
    }
}
