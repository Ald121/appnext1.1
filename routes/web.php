<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| This file is where you may define all of the routes that are handled
| by your application. Just tell Laravel the URIs it should respond
| to using a Closure or controller method. Build something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::group(['middleware' => 'cors'], function(){
    Route::post('Save_Datos_Ruc','RegistroController@Save_Datos_Ruc');
	Route::post('Buscar_Empresas','busquedaEmpresas@Buscar_Empresas');
	// --------------------- Datos de Perfil Empresa----------------------------------
    Route::post('Get_Perfil_Empresas', 'busquedaEmpresas@Get_Perfil_Empresas');
    // --------------------- Buscar Empresa----------------------------------
    Route::post('Buscar_Informacion_Ruc', 'RegistroController@Buscar_Informacion_Ruc');
    // --------------------- GET provincias ----------------------------------
    Route::post('Get_Provincias', 'RegistroController@Get_Provincias'); 
    // --------------------- ACTIVAR CUENTA  ----------------------------------
    Route::post('Activar_Cuenta', 'RegistroController@Activar_Cuenta');
    // Ingreso
     Route::post('Acceso','loginController@Acceso');

    Route::group(['middleware' => ['auth.nextbook']], function ()
    { 
    });
});
