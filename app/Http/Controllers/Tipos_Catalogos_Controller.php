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
class Tipos_Catalogos_Controller extends Controller
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
    public function Existencia_Tipo_Catalogo(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('inventario.tipos_catalogos')->where('estado','A')->where('nombre',$request->nombre)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }
    public function Add_Tipo_Catalogo(Request $request)
    {
        DB::connection($this->name_bdd)->table('inventario.tipos_catalogos')->insert(['nombre' => $request->nombre,'fecha_inicio' => $request->fecha_inicio ,'fecha_fin' => $request->fecha_fin,'descripcion' => $request->descripcion, 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
        return response()->json(['respuesta' => true], 200);
    }

    public function Get_Tipo_Catalogos(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    if ($request->has('filter')&&$request->filter!='') {
        //$data=DB::connection($this->name_bdd)->statement("SELECT * FROM inventario.tipos_categorias WHERE (nombre||descripcion) like '%".$request->input('filter')."%' and estado='A' LIMIT 5");
        $data=DB::connection($this->name_bdd)->table('inventario.tipos_catalogos')
                                                ->where('nombre','LIKE','%'.$request->input('filter').'%')
                                                //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->where('estado','A')->orderBy('nombre','ASC')->get();
    }else{
        $data=DB::connection($this->name_bdd)->table('inventario.tipos_catalogos')->select('id', 'nombre', 'descripcion', 'fecha_inicio', 'fecha_fin')->where('estado','A')->orderBy('nombre','ASC')->get();
    }
    foreach ($data as $key => $value) {
            $value->fecha_inicio= Carbon::parse($value->fecha_inicio)->format('Y/m/d');
            $value->fecha_fin= Carbon::parse($value->fecha_fin)->format('Y/m/d');
        }
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Tipo_Catalogo(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.tipos_catalogos')->where('id',$request->id)->update(['nombre' => $request->nombre , 'fecha_inicio' => $request->fecha_inicio ,'fecha_fin' => $request->fecha_fin,'descripcion' => $request->descripcion]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Tipo_Catalogo(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.tipos_catalogos')->where('id',$request->id)->update(['estado'=>'P']);
    return response()->json(['respuesta' => true], 200);
    }
}
