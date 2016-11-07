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
    	'nombre_corto'=>$request->input('nombre_corto'),
		'vendible'=>$request->input('vendible'),
		'comprable'=>$request->input('comprable'),
		'precio'=>$request->input('precio'),
		'costo'=>$request->input('costo'),
		'estado_descriptivo'=>$request->input('estado_descriptivo'),
		'categoria'=>$request->input('categoria'),
		'garantia'=>$request->input('garantia'),
		'marca'=>$request->input('marca'),
		'modelo'=>$request->input('modelo'),
		'ubicacion'=>$request->input('ubicacion'),
		'cantidad'=>$request->input('cantidad'),
		'descripcion'=>$request->input('descripcion'),
		'codigo_baras'=>$request->input('codigo_baras')
    	]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Productos(Request $request)
    {
    $currentPage = $request->input('pagina_actual');
    $limit = $request->input('limit');
    $data=DB::connection('nextbookPRE')->table('inventario.productos')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
}
