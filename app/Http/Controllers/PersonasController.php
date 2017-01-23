<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
use \Firebase\JWT\JWT;
use Config;
// Funciones
use App\libs\Funciones;

class PersonasController extends Controller
{
    public function __construct(Request $request){
        // Funciones
        $this->funciones=new Funciones();
        //Autenticacion
        $key=config('jwt.secret');
        $decoded = JWT::decode($request->token, $key, array('HS256'));
        $this->user=$decoded;
        $this->name_bdd=$this->user->nbdb;
    }
    
    public function Existencia_Persona(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('public.personas')->where('estado','A')->where('nombre',$request->nombre)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }
   public function Add_Persona(Request $request)
    {
    $actual_date=Carbon::now()->setTimezone('America/Guayaquil')->toDateTimeString();
    DB::connection($this->name_bdd)->table('public.personas')->insert(
    [
    'primer_nombre'=>$request->primer_nombre,
     'segundo_nombre'=>$request->segundo_nombre,
     'primer_apellido'=>$request->primer_apellido,
     'segundo_apellido'=>$request->segundo_apellido,
     'id_localidad'=>$request->id_localidad,
     'calle'=>$request->calle,
     'transversal'=>$request->transversal,
     'numero'=>$request->numero
    ]);
    $id_persona=DB::connection($this->name_bdd)->select('id')->where('primer_nombre',$request->primer_nombre)->first();
    // Guardar DOcumento
    $actual_date=Carbon::now()->setTimezone('America/Guayaquil')->toDateTimeString();
    DB::connection($this->name_bdd)->table('public.personas_documentos_identificacion')->insert(
    [
    'id_persona'=>$id_persona->id,
     'id_tipo_documento'=>$request->tipo_documento,
     'numero_identificaion'=>$request->numero_documento,
     'estado'=>'A',
     'fecha'=>$actual_date
    ]);
    //Guardar Correo
    $actual_date=Carbon::now()->setTimezone('America/Guayaquil')->toDateTimeString();
    DB::connection($this->name_bdd)->table('public.personas_correo_electronico')->insert(
    [
    'id_persona'=>$id_persona->id,
     'correo_electronico'=>$request->correo,
     'estado'=>'A',
     'fecha'=>$actual_date
    ]);
    //Guardar Telefono
    $actual_date=Carbon::now()->setTimezone('America/Guayaquil')->toDateTimeString();
    DB::connection($this->name_bdd)->table('public.telefonos_personas')->insert(
    [
    'id_persona'=>$id_persona->id,
     'numero'=>$request->numero_telefono,
     'estado'=>'A',
     'fecha'=>$actual_date,
     'id_operadora_telefonica'=>$request->operadora
    ]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Personas(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    if ($request->has('filter')&&$request->filter!='') {
        $data=DB::connection($this->name_bdd)->table('public.personas')
                                                ->where('nombre','LIKE','%'.$request->input('filter').'%')
                                                //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->where('estado','A')->orderBy('nombre','ASC')->get();
    }else{
        $data=$data=DB::connection($this->name_bdd)->table('public.personas')->where('estado','A')->orderBy('nombre','ASC')->get();
    }
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Persona(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('public.personas')->where('id',$request->id)->update(['tipo_catalogo' => $request->tipo_catalogo , 'producto' => $request->producto]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Persona(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('public.personas')->where('id',$request->id)->update(['estado'=>'P']);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Operadoras(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('public.operadoras_telefonicas')->select('id',
                                                                                                'nombre',
                                                                                                'descripcion')
                                                                                       ->where('estado','A')->orderBy('nombre','ASC')->get();
    return response()->json(['respuesta' => $data], 200);
    }
}
