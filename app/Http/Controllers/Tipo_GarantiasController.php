<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
	// Funciones
use App\libs\Funciones;
class Tipo_GarantiasController extends Controller
{

	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
    public function Add_Tipo_Garantia(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.tipos_garantias')->insert(['nombre' => $request->nombre , 'descripcion' => $request->descripcion , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString() ]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Tipo_Garantias(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection('nextbookPRE')->table('inventario.tipos_garantias')->where('estado','A')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Tipo_Garantia(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.tipos_garantias')->where('id',$request->id)->update(['nombre' => $request->nombre , 'descripcion' => $request->descripcion]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Tipo_Garantia(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.tipos_garantias')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }
}
