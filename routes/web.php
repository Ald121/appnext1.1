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
    Route::get('crear_bdd','pruebasController@crear_bdd');
	Route::post('Buscar_Empresas','busquedaEmpresas@Buscar_Empresas');
	// --------------------- Datos de Perfil Empresa----------------------------------
    Route::post('Get_Perfil_Empresas', 'busquedaEmpresas@Get_Perfil_Empresas');
    // --------------------- Buscar Empresa----------------------------------
    Route::post('Buscar_Informacion_Ruc', 'RegistroController@Buscar_Informacion_Ruc');
    // --------------------- GET provincias ----------------------------------
    Route::post('Get_Provincias', 'RegistroController@Get_Provincias'); 
    // --------------------- GET CIUDADES ----------------------------------
    Route::post('Get_Ciudades', 'RegistroController@Get_Ciudades'); 
    // --------------------- ACTIVAR CUENTA  ----------------------------------
    Route::post('Activar_Cuenta', 'RegistroController@Activar_Cuenta');
    // Ingreso
    Route::post('Acceso','loginController@Acceso');
    // Accesso Colaboradores
    Route::post('Acceso_Colaborador', 'loginController@Acceso_Colaborador');
    Route::post('Get_Data_By_Ruc', 'loginController@Get_Data_By_Ruc');
    Route::group(['middleware' => ['auth.nextbook']], function ()
    {
        // ////////////////////////////////////////////////// IMAGENES DE PERFIL //////////////
        // --------------------------------------- AÑADIR IMAGEN DE PERFIL -----------
        Route::post('Add_Img_Perfil', 'PerfilController@Add_Img_Perfil');
        // --------------------------------------- SELECCIONAR IMAGEN DE PERFIL -----------
        Route::post('Set_Img_Perfil', 'PerfilController@Set_Img_Perfil');
        // --------------------------------------- CARGAR IMAGENES PERFIL -----------
        Route::post('Load_Imgs_Perfil', 'PerfilController@Load_Imgs_Perfil');
        // --------------------------------------- GET IMAGENES PERFIL -----------
        Route::post('Get_Img_Perfil', 'PerfilController@Get_Img_Perfil');
        // --------------------------------------- DELETE IMAGENES PERFIL -----------
        Route::post('Delete_Img_Perfil', 'PerfilController@Delete_Img_Perfil');
                                // ////////////////////////////////////////////////// IMAGENES DE LOGO //////////////
        // --------------------------------------- AÑADIR IMAGEN DE LOGO -----------
        Route::post('Add_Img_Logo', 'LogoController@Add_Img_Logo');
        // --------------------------------------- SELECCIONAR IMAGEN DE LOGO -----------
        Route::post('Set_Img_Logo', 'LogoController@Set_Img_Logo');
        // --------------------------------------- CARGAR IMAGENES LOGO -----------
        Route::post('Load_Imgs_Logo', 'LogoController@Load_Imgs_Logo');
        // --------------------------------------- GET IMAGENES LOGO -----------
        Route::post('Get_Img_Logo', 'LogoController@Get_Img_Logo');
        // --------------------------------------- DELETE IMAGENES LOGO -----------
        Route::post('Delete_Img_Logo', 'LogoController@Delete_Img_Logo');
        // ////////////////////////////////////////////////// IMAGENES DE PORTADA //////////////
        // --------------------------------------- AÑADIR IMAGEN DE PORTADA -----------
        Route::post('Add_Img_Portada', 'PortadaController@add_img_portada');
        // --------------------------------------- SELECCIONAR IMAGEN DE PORTADA -----------
        Route::post('Set_Img_Portada', 'PortadaController@Set_Img_Portada');
        // --------------------------------------- CARGAR IMAGENES PORTADA -----------
        Route::post('Load_Imgs_Portada', 'PortadaController@Load_Imgs_Portada');
        // --------------------------------------- GET IMAGENES PORTADA -----------
        Route::post('Get_Img_Portada', 'PortadaController@Get_Img_Portada');
        // --------------------------------------- DELETE IMAGENES PERFIL -----------
        Route::post('Delete_Img_Portada', 'PortadaController@Delete_Img_Portada');
        // GET DATOS EMPRESA
        Route::post('Get_Datos_Empresa', 'Administracion_Empresa_Controller@Get_Datos_Empresa');
        //GETESTABLECIMIENTOS
        Route::post('Get_Establecimientos', 'Administracion_Empresa_Controller@Get_Establecimientos');
        //UPDATE PASSWORD
        Route::post('Update_Password', 'Administracion_Empresa_Controller@Update_Password');

        // Categorias
        Route::post('Add_Categoria','categoriasController@Add_Categoria');
        Route::post('Get_Categorias','categoriasController@Get_Categorias');
        Route::post('Update_Categoria','categoriasController@Update_Categoria');
        Route::post('Delete_Categoria','categoriasController@Delete_Categoria');
        // Tipo Categorias
        Route::post('Existencia_Tipo_Categoria','Tipos_Categorias_Controller@Existencia_Tipo_Categoria');
        Route::post('Existencia_Update_Tipo_Categoria','Tipos_Categorias_Controller@Existencia_Update_Tipo_Categoria');
        Route::post('Add_Tipo_Categoria','Tipos_Categorias_Controller@Add_Tipo_Categoria');
        Route::post('Get_Tipo_Categorias','Tipos_Categorias_Controller@Get_Tipo_Categorias');
        Route::post('Delete_Tipo_Categorias','Tipos_Categorias_Controller@Delete_Tipo_Categorias');
        Route::post('Update_Tipo_Categorias','Tipos_Categorias_Controller@Update_Tipo_Categorias');
        // Marcas
        Route::post('Existencia_Marca','MarcasController@Existencia_Marca');
        Route::post('Add_Marca','MarcasController@Add_Marca');
        Route::post('Get_Marcas','MarcasController@Get_Marcas');
        Route::post('Update_Marca','MarcasController@Update_Marca');
        Route::post('Delete_Marca','MarcasController@Delete_Marca');
        // Tipo Garantias
        Route::post('Existencia_Tipo_Garantia','Tipos_GarantiasController@Existencia_Tipo_Garantia');
        Route::post('Add_Tipo_Garantia','Tipos_GarantiasController@Add_Tipo_Garantia');
        Route::post('Get_Tipo_Garantias','Tipos_GarantiasController@Get_Tipo_Garantias');
        Route::post('Update_Tipo_Garantia','Tipos_GarantiasController@Update_Tipo_Garantia');
        Route::post('Delete_Tipo_Garantia','Tipos_GarantiasController@Delete_Tipo_Garantia');
        // Garantias
        Route::post('Existencia_Garantia','GarantiasController@Existencia_Garantia');
        Route::post('Add_Garantia','GarantiasController@Add_Garantia');
        Route::post('Get_Garantias','GarantiasController@Get_Garantias');
        Route::post('Update_Garantia','GarantiasController@Update_Garantia');
        Route::post('Delete_Garantia','GarantiasController@Delete_Garantia');
        // Modelos
        Route::post('Existencia_Modelo','ModelosController@Existencia_Modelo');
        Route::post('Add_Modelo','ModelosController@Add_Modelo');
        Route::post('Get_Modelos','ModelosController@Get_Modelos');
        Route::post('Update_Modelo','ModelosController@Update_Modelo');
        Route::post('Delete_Modelo','ModelosController@Delete_Modelo');
        // Tipo Consumos
        Route::post('Existencia_Tipo_Consumo','Tipo_Consumo_Controller@Existencia_Tipo_Consumo');
        Route::post('Add_Tipo_Consumo','Tipo_Consumo_Controller@Add_Tipo_Consumo');
        Route::post('Get_Tipo_Consumos','Tipo_Consumo_Controller@Get_Tipo_Consumos');
        Route::post('Update_Tipo_Consumo','Tipo_Consumo_Controller@Update_Tipo_Consumo');
        Route::post('Delete_Tipo_Consumo','Tipo_Consumo_Controller@Delete_Tipo_Consumo');
        // Ubicaciones
        Route::post('Existencia_Ubicacion','UbicacionesController@Existencia_Ubicacion');
        Route::post('Add_Ubicacion','UbicacionesController@Add_Ubicacion');
        Route::post('Get_Ubicaciones','UbicacionesController@Get_Ubicaciones');
        Route::post('Update_Ubicacion','UbicacionesController@Update_Ubicacion');
        Route::post('Delete_Ubicacion','UbicacionesController@Delete_Ubicacion');
        // Productos
        Route::post('Add_Producto','ProductosController@Add_Producto');
        Route::post('Get_Productos','ProductosController@Get_Productos');
        // Tipo Producto
        Route::post('Existencia_Tipo_Producto','Tipos_Productos_Controller@Existencia_Tipo_Producto');
        Route::post('Add_Tipo_Producto','Tipos_Productos_Controller@Add_Tipo_Producto');
        Route::post('Get_Tipo_Productos','Tipos_Productos_Controller@Get_Tipo_Productos');
        Route::post('Update_Tipo_Producto','Tipos_Productos_Controller@Update_Tipo_Producto');
        Route::post('Delete_Tipo_Producto','Tipos_Productos_Controller@Delete_Tipo_Producto');
        // Tipos Catalogos
        Route::post('Existencia_Tipo_Catalogo','Tipos_Catalogos_Controller@Existencia_Tipo_Catalogo');
        Route::post('Add_Tipo_Catalogo','Tipos_Catalogos_Controller@Add_Tipo_Catalogo');
        Route::post('Get_Tipo_Catalogos','Tipos_Catalogos_Controller@Get_Tipo_Catalogos');
        Route::post('Update_Tipo_Catalogo','Tipos_Catalogos_Controller@Update_Tipo_Catalogo');
        Route::post('Delete_Tipo_Catalogo','Tipos_Catalogos_Controller@Delete_Tipo_Catalogo');
         // Catalogos
        Route::post('Add_Catalogo','CatalogosController@Add_Catalogo');
        Route::post('Get_Catalogos','CatalogosController@Get_Catalogos');
        Route::post('Update_Catalogo','CatalogosController@Update_Catalogo');
        Route::post('Delete_Catalogo','CatalogosController@Delete_Catalogo');
        // Estado Descriptivo
        Route::post('Existencia_Estado_Descriptivo','Estado_Descriptivo_Controller@Existencia_Estado_Descriptivo');
        Route::post('Add_Estado_Descriptivo','Estado_Descriptivo_Controller@Add_Estado_Descriptivo');
        Route::post('Get_Estados_Descriptivos','Estado_Descriptivo_Controller@Get_Estados_Descriptivos');
        Route::post('Update_Estado_Descriptivo','Estado_Descriptivo_Controller@Update_Estado_Descriptivo');
        Route::post('Delete_Estado_Descriptivo','Estado_Descriptivo_Controller@Delete_Estado_Descriptivo');
        // Bodegas
        Route::post('Existencia_Bodega','BodegasController@Existencia_Bodega');
        Route::post('Add_Bodega','BodegasController@Add_Bodega');
        Route::post('Get_Bodegas','BodegasController@Get_Bodegas');
        Route::post('Update_Bodega','BodegasController@Update_Bodega');
        Route::post('Delete_Bodega','BodegasController@Delete_Bodega');
        // Colaboradores
        //Route::post('Acceso_Colaborador', 'ColaboradoresController@Acceso_Colaborador');
        Route::post('Existencia_Usuario_Cedula', 'ColaboradoresController@Existencia_Usuario_Cedula');
        Route::post('Existencia_Usuario_Correo', 'ColaboradoresController@Existencia_Usuario_Correo');
        Route::post('Existencia_Usuario_Nick', 'ColaboradoresController@Existencia_Usuario_Nick');
        Route::post('Gen_Vistas_Admin', 'ColaboradoresController@Gen_Vistas_Admin');
        Route::post('Add_Col_Usuario', 'ColaboradoresController@Add_Col_Usuario');
        Route::post('Get_Col_Usuario', 'ColaboradoresController@Get_Col_Usuario');
        Route::post('Delete_Col_Usuario', 'ColaboradoresController@Delete_Col_Usuario');
        Route::post('Get_Col_Usuario_Update', 'ColaboradoresController@Get_Col_Usuario_Update');
        Route::post('Update_Col_Usuario', 'ColaboradoresController@Update_Col_Usuario');
        // Tipos de Usuario
        Route::post('Existencia_Tipo_Usuario','Tipo_UsuarioController@Existencia_Tipo_Usuario');
        Route::post('Add_Tipo_Usuario','Tipo_UsuarioController@Add_Tipo_Usuario');
        Route::post('Get_Tipo_Usuarios','Tipo_UsuarioController@Get_Tipo_Usuarios');
        Route::post('Get_Vistas_By_Tipo_User','Tipo_UsuarioController@Get_Vistas_By_Tipo_User');
        Route::post('Update_Tipo_Usuario','Tipo_UsuarioController@Update_Tipo_Usuario');
        Route::post('Delete_Tipo_Usuario','Tipo_UsuarioController@Delete_Tipo_Usuario');
        //Tipo de Documento
        Route::post('Get_Tipo_Documentos','Tipo_DocumentosController@Get_Tipo_Documentos');
        //Operadoras
        Route::post('Get_Operadoras','PersonasController@Get_Operadoras');
        //Get Vistas
        Route::post('Get_Vistas', 'ColaboradoresController@Get_Vistas');
        //Privilegios
        Route::post('Get_Combinacion_Privilegios', 'Tipo_UsuarioController@Get_Combinacion_Privilegios');
        // REPOSITORIO DE FACTURAS -------------------
        Route::post('Upload_XML', 'Repositorio_Facturas_Controller@Upload_XML');
        Route::post('Upload_Factura', 'Repositorio_Facturas_Controller@Upload_Factura');
        //FACTURAS CORREO
        Route::post('Leer_Facturas_Correo', 'Repositorio_Facturas_Controller@Leer_Facturas_Correo');
        //FACTURAS RECHAZADAS
        Route::post('Get_Facturas_Rechazadas', 'Repositorio_Facturas_Controller@Get_Facturas_Rechazadas');

        // Tipos de Gasto
        Route::post('Existencia_Gasto','GastosController@Existencia_Gasto');
        Route::post('Add_Gasto','GastosController@Add_Gasto');
        Route::post('Get_Gastos','GastosController@Get_Gastos');
        Route::post('Update_Gasto','GastosController@Update_Gasto');
        Route::post('Delete_Gasto','GastosController@Delete_Gasto');
    });
});

