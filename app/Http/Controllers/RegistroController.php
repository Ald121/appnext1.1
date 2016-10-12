<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Requests;
// Modelos
use App\empresas;
use App\libs\Funciones;
// Extras
use DateTime;

class RegistroController extends Controller
{
    public function __construct(){
    	// Modelos
    	$this->conceptual_users=new empresas();
    	// Funciones
    	$this->funciones=new Funciones();
    }

    public function registrar_E(Request $request){

    	$this->conceptual_users->id=$this->funciones->generarID(); 
    	$this->conceptual_users->razon_social=$request->input('razon_social'); 
    	$this->conceptual_users->actividad_economica=$request->input('actividad_economica'); 
    	$this->conceptual_users->ruc_ci=$request->input('ruc_ci'); 
    	$this->conceptual_users->estdo_contribuyente=$request->input('estdo_contribuyente'); 
       $this->conceptual_users->fecha_inicio_actividades=$request->input('fecha_inicio_actividades'); 
       $this->conceptual_users->nombre_comercial=$request->input('nombre_comercial'); 
       $this->conceptual_users->obligado_lleva_contabilida=$request->input('obligado_lleva_contabilida'); 
       $this->conceptual_users->tipo_contribuyente=$request->input('tipo_contribuyente'); 
       $this->conceptual_users->id_estado='A';
       $this->conceptual_users->fecha_creacion=new DateTime();
    	$save=$this->conceptual_users->save();
    	// if ($save) {
    		return response()->json(['respuesta'=>$save],200);
    	// }
    	
    }
}
