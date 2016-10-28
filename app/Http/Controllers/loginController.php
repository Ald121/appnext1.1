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
    }

    public function Acceso(Request $request){
        // $credentials = ['nick' => $request->nick, 'password' => $request->clave_clave];

        $datos=$this->usuarios->select('nick')->where('id',$request->nick)->get();

        $name_bdd = $datos[0]['nick'];

        $name_bdd=strtolower($datos[0]['nick']);

        Config::set('database.connections.'.$name_bdd, array(
                'driver' => 'pgsql',
                'host' => 'localhost',
                'port' =>  '5432',
                'database' =>  $name_bdd,
                'username' =>  $name_bdd,
                'password' =>  $request->nick,
                'charset' => 'utf8',
                'prefix' => '',
                'schema' => 'public',
                'sslmode' => 'prefer',
        ));
        $usuarios=new Usuarios(); 
        $usuarios->changeConnection($name_bdd);
        $user=$request->nick.'@facturanext.com';

        $json['ip_cliente']=$request->input('ip_cliente');
        $json['macadress']=$request->input('macadress');
        $this->ingresos_usuarios->usuario=$request->input('acceso');
        $this->ingresos_usuarios->ip_acceso=json_encode($json);
        $this->ingresos_usuarios->informacion_servidor=$request->input('info_servidor');
        $this->ingresos_usuarios->fecha=Carbon::now()->toDateString();
        $this->ingresos_usuarios->save();

        $datos=$usuarios->select('clave_clave')->where('nick',$user)->first();
        $checkpass=Hash::check($request->clave_clave, $datos['clave_clave']);

        if ($checkpass) {
         $datos = $usuarios->select('id','nick')->where('nick',$user)->first();
         $token = JWTAuth::fromUser($datos);

         $usuarios->where('nick',$user)->update(["token"=>$token]);
         return response()->json(compact('token'));
        }
        return response()->json(["respuesta"=>$checkpass]);
           
    }
}
