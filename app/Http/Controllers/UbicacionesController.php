<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
	// Funciones
use App\libs\Funciones;
class UbicacionesController extends Controller
{

	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
    public function Add_Ubicacion(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.ubicaciones')->insert(['nombre' => $request->input('nombre') , 'descripcion' => $request->input('descripcion') , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }
    public function Get_Ubicaciones(Request $request)
    {
    $currentPage = $request->input('pagina_actual');
    $limit = $request->input('limit');
    $data=DB::connection('nextbookPRE')->table('inventario.ubicaciones')->select('nombre','descripcion')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
}
