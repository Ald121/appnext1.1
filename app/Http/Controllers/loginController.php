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
use DB;
use Config;
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
        $user=$acceso->nick.'001'.config('global.dominio');

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

    public function Acceso_Colaborador(Request $request){
        $acceso=$request->acceso;
        //return response()->json(["respuesta"=>$acceso]);
        // $credentials = ['nick' => $request->nick, 'password' => $request->clave_clave];
        $datos=$this->usuarios->select('nick','id')->where('id',$acceso['ruc'])->get();
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
        $user=$acceso['nick'].config('global.dominio');
        /*$json['ip_cliente']=$request->input('ip_cliente');
        $json['macadress']=$request->input('macadress');
        $this->ingresos_usuarios->usuario=$request->input('acceso');
        $this->ingresos_usuarios->ip_acceso=json_encode($json);
        $this->ingresos_usuarios->informacion_servidor=$request->input('info_servidor');
        $this->ingresos_usuarios->fecha=Carbon::now()->toDateString();
        $this->ingresos_usuarios->save();*/

        $datos=DB::connection($name_bdd)->table('usuarios.usuarios')->select('clave_clave')->where('nick',$user)->where('id_estado','A')->first();
        //return response()->json(["respuesta"=>$datos]);
        if (count($datos)==0) {
            return response()->json(["respuesta"=>false]);
        }
        $checkpass=Hash::check($acceso['clave'], $datos->clave_clave);

        if ($checkpass) {
         $datos = $usuarios->select('id','nick')->where('nick',$user)->where('id_estado','A')->first();
         $extra=['nbdb'=>$name_bdd,'pnb'=>$pass_bdd,'ruc'=>$acceso['ruc']];
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
            'fecha_creacion')->where('id_estado','A')->where('ruc_ci',$acceso['ruc'])->first();
         //Cargar Datos Usuario
        $empleado=DB::connection($name_bdd)->table('talento_humano.empleados')->select('id_persona')->where('id_usuario',$datos->id)->first();
        $usuario=DB::connection($name_bdd)->table('usuarios.usuarios')->select('nick')->where('id',$datos->id)->first();
        $persona=DB::connection($name_bdd)->table('public.personas')->where('id',$empleado->id_persona)->first();
        $correo=DB::connection($name_bdd)->table('public.personas_correo_electronico')->where('id_persona',$persona->id)->first();
        $ciudad=DB::connection('localidadesconex')->select("SELECT nombre,id,codigo_telefonico FROM view_localidades WHERE id='".$persona->id_localidad."' and nombre!='ECUADOR' ORDER BY nombre ASC");
        $data_nick=explode('@', $usuario->nick);
        $persona->nick=$data_nick[0];
        $persona->id_user=$request->id;
        $persona->id_localidad=$ciudad[0];
        $persona->correo_electronico=$correo->correo_electronico;
        $persona->id_correo=$correo->id;

         //$usuarios->where('nick',$user)->update(["token"=>$token]);
         return response()->json(['respuesta'=>true,'token'=>$token,'datosE'=>$datosE,'datosPersona'=>$persona]);
        }
        return response()->json(["respuesta"=>$checkpass]);
        //return response()->json(["respuesta"=>$name_bdd]);
           
    }

    public function Get_Data_By_Ruc(Request $request){

        $datos=$this->usuarios->select('nick','id')->where('id',$request->ruc)->get();
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
        $img=DB::connection($name_bdd)->table('administracion.imagen_empresa')->select('direccion_imagen_empresa')->where('estado','A')->first();
        $dataE=DB::connection($name_bdd)->table('administracion.empresas')->select('razon_social')->where('id_estado','A')->first();
        if ($img==null) {
            $img="http://186.4.167.12/appnext1.1/storage/default/portada-default.jpg";
        }
        $dataE->img_portada=$img;
        return response()->json(["respuesta"=>$dataE]);
    }
}
