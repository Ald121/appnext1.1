<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
// Funciones
use App\libs\Funciones;

class GarantiasController extends Controller
{
    public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
   	public function Add_Garantia(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.garantias')->insert(['nombre' => $request->nombre , 'descripcion' => $request->descripcion ,'tipo_garantia' => $request->tipo_garantia,'duracion' => $request->duracion, 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Garantias(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection('nextbookPRE')->table('inventario.garantias')->where('estado','A')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Garantia(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.garantias')->where('id',$request->id)->update(['nombre' => $request->nombre , 'descripcion' => $request->descripcion ,'tipo_garantia' => $request->tipo_garantia,'duracion' => $request->duracion]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Garantia(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.garantias')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }
}
