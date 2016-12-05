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
class ProductosController extends Controller
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

    public function Existencia_Producto(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('inventario.productos')->where('nombre_corto',$request->nombre)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }

    public function Add_Producto(Request $request)
    {
    DB::connection($this->name_bdd)->table('inventario.productos')->insert([
    	'nombre_corto'=>$request->nombre_corto,
		'vendible'=>$request->vendible,
		'comprable'=>$request->comprable,
		'precio'=>$request->precio,
		'costo'=>$request->costo,
		'estado_descriptivo'=>$request->estado_descriptivo,
		'categoria'=>$request->categoria,
		'garantia'=>$request->garantia,
		'marca'=>$request->marca,
		'modelo'=>$request->modelo,
		'ubicacion'=>$request->ubicacion,
		'cantidad'=>$request->cantidad,
		'descripcion'=>$request->descripcion,
		'codigo_baras'=>$request->codigo_baras
    	]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Productos(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection($this->name_bdd)->table('inventario.productos')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
}
