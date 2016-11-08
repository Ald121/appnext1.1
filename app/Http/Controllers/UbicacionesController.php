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
    DB::connection('nextbookPRE')->table('inventario.ubicaciones')->insert(['nombre' => $request->nombre , 'descripcion' => $request->descripcion , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }
    public function Get_Ubicaciones(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection('nextbookPRE')->table('inventario.ubicaciones')->where('estado','A')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
    
    public function Update_Ubicacion(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.ubicaciones')->where('id',$request->id)->update(['nombre' => $request->nombre ,'descripcion' => $request->descripcion]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Ubicacion(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.ubicaciones')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }
}
