<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
use \Firebase\JWT\JWT;
use Config;
// Funciones
use App\libs\Funciones;

class CatalogosController extends Controller
{
    public function __construct(Request $request){
        // Funciones
        $this->funciones=new Funciones();
        //Autenticacion
        $key=config('jwt.secret');
        $decoded = JWT::decode($request->token, $key, array('HS256'));
        $this->user=$decoded;
        $this->name_bdd=$this->user->nbdb;
    }
    
   public function Add_Catalogo(Request $request)
    {
    DB::connection($this->name_bdd)->table('inventario.catalogos')->insert(['tipo_catalogo' => $request->tipo_catalogo , 'producto' => $request->producto]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Catalogos(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection($this->name_bdd)->table('inventario.catalogos')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Catalogo(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.catalogos')->where('id',$request->id)->update(['tipo_catalogo' => $request->tipo_catalogo , 'producto' => $request->producto]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Catalogo(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.catalogos')->where('id',$request->id)->update(['estado'=>'P']);
    return response()->json(['respuesta' => true], 200);
    }
}
