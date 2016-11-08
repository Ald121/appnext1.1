<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
	// Funciones
	use App\libs\Funciones;
class MarcasController extends Controller
{
	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
    public function Add_Marca(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.marcas')->insert(['nombre' => $request->nombre , 'descripcion' => $request->descripcion , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Marcas(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection('nextbookPRE')->table('inventario.marcas')->where('estado','A')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Marca(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.marcas')->where('id',$request->id)->update(['nombre' => $request->nombre , 'descripcion' => $request->descripcion]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Marca(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.marcas')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }
}
