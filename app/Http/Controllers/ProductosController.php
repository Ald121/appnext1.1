<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
	// Funciones
use App\libs\Funciones;
class ProductosController extends Controller
{

	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
    public function Add_Producto(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.productos')->insert([
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
    $data=DB::connection('nextbookPRE')->table('inventario.productos')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
}
