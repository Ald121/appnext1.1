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
class Tipo_Consumo_Controller extends Controller
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
    public function Existencia_Tipo_Consumo(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('inventario.tipo_consumo')->where('estado','A')->where('nombre',$request->nombre)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }
    
    public function Add_Tipo_Consumo(Request $request)
    {
    DB::connection($this->name_bdd)->table('inventario.tipo_consumo')->insert(['nombre' => $request->nombre , 'descripcion' => $request->descripcion , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Tipo_Consumos(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    if ($request->has('filter')&&$request->filter!='') {
        //$data=DB::connection($this->name_bdd)->statement("SELECT * FROM inventario.tipos_categorias WHERE (nombre||descripcion) like '%".$request->input('filter')."%' and estado='A' LIMIT 5");
        $data=DB::connection($this->name_bdd)->table('inventario.tipo_consumo')->where('estado','A')
                                                ->where('nombre','LIKE','%'.$request->input('filter').'%')
                                                //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->orderBy('nombre','ASC')->get();
    }else{
        $data=DB::connection($this->name_bdd)->table('inventario.tipo_consumo')->where('estado','A')->orderBy('nombre','ASC')->get();
    }
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Tipo_Consumo(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.tipo_consumo')->where('id',$request->id)->update(['nombre' => $request->nombre ,'descripcion' => $request->descripcion]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Tipo_Consumo(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.tipo_consumo')->where('id',$request->id)->update(['estado'=>'P']);
    return response()->json(['respuesta' => true], 200);
    }
}
