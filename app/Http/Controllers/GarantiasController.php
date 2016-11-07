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
    DB::connection('nextbookPRE')->table('inventario.garantias')->insert(['nombre' => $request->input('nombre') , 'descripcion' => $request->input('descripcion') ,'tipo_garantia' => $request->input('tipo_garantia'),'duracion' => $request->input('duracion'), 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }
}
