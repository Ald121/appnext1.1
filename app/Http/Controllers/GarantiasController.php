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

class GarantiasController extends Controller
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
   	public function Add_Garantia(Request $request)
    {
    DB::connection($this->name_bdd)->table('inventario.garantias')->insert(['nombre' => $request->nombre , 'descripcion' => $request->descripcion ,'tipo_garantia' => $request->tipo_garantia,'duracion' => $request->duracion, 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Garantias(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection($this->name_bdd)->table('inventario.garantias')->where('estado','A')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Garantia(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.garantias')->where('id',$request->id)->update(['nombre' => $request->nombre , 'descripcion' => $request->descripcion ,'tipo_garantia' => $request->tipo_garantia,'duracion' => $request->duracion]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Garantia(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.garantias')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }
}
