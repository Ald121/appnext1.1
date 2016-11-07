<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
	// Funciones
use App\libs\Funciones;
class Tipos_Productos_Controller extends Controller
{

	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
    public function Add_Tipo_Productos(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.tipos_productos')->insert(['nombre' => $request->input('nombre') , 'descripcion' => $request->input('descripcion') , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Tipo_Productos(Request $request)
    {
    $currentPage = $request->input('pagina_actual');
    $limit = $request->input('limit');
    $data=DB::connection('nextbookPRE')->table('inventario.tipos_productos')->select('nombre','descripcion')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
}
