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

class BodegasController extends Controller

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

    public function Existencia_Bodega(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('inventario.bodegas')->where('estado','A')->where('nombre',$request->nombre)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }

  	public function Add_Bodega(Request $request)
    {
    DB::connection($this->name_bdd)->table('inventario.bodegas')->insert([
    	'id_sucursal'=>$request->input('id_sucursal'),
    	'nombre'=>$request->input('nombre'),
    	'calle'=>$request->input('calle'),
    	'numero'=>$request->input('numero'),
    	'especificaciones'=>$request->input('especificaciones'), 
       	'estado'=>'A',
       	'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Bodegas(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;

    if ($request->has('filter')&&$request->filter!='') {
        //$data=DB::connection($this->name_bdd)->statement("SELECT * FROM inventario.tipos_Bodegas WHERE (nombre||descripcion) like '%".$request->input('filter')."%' and estado='A' LIMIT 5");
        $data=DB::connection($this->name_bdd)->table('inventario.bodegas')
                                                ->where('nombre','LIKE','%'.$request->input('filter').'%')
                                                //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->where('estado','A')->orderBy('nombre','ASC')->get();
    }else{
        $data=DB::connection($this->name_bdd)->table('inventario.bodegas')->where('estado','A')->orderBy('nombre','ASC')->get();
    }
    /*foreach ($data as $key => $value) {
        $categoria=DB::connection($this->name_bdd)->table('inventario.tipos_Bodegas')->select('id','nombre','descripcion')->where('id',$value->tipo_Bodega)->where('estado','A')->first();
        $value->tipo_Bodega=$categoria;
    }*/
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Bodega(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.bodegas')->where('id',$request->id)->update([
    	'nombre'=>$request->input('nombre'),
    	'calle'=>$request->input('calle'),
    	'numero'=>$request->input('numero'),
    	'especificaciones'=>$request->input('especificaciones')
    	]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Bodega(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.bodegas')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }

  
  }

