<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
// Funciones
use App\libs\Funciones;

class CatalogosController extends Controller
{
    public function __construct(){
        // Funciones
        $this->funciones=new Funciones();
    }
   public function Add_Catalogo(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.catalogos')->insert(['tipo_catalogo' => $request->input('tipo_catalogo') , 'producto' => $request->input('producto')]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Catalogos(Request $request)
    {
    $currentPage = $request->input('pagina_actual');
    $limit = $request->input('limit');
    $data=DB::connection('nextbookPRE')->table('inventario.catalogos')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
}
