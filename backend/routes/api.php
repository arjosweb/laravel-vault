<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

// API Running
Route::get('', function () {
    return response()->json(['status_code' => 200]);
});

// AUTHENTICATION API V1
Route::prefix('v1/auth')->name('api.v1.auth.')->group(function () {
    /* Login */
    Route::post('login',  [AuthController::class, 'login'])->name('login');
    /* Logout */
    Route::post('logout', [AuthController::class, 'logout'])->name('logout');
    /* Me (User Logged) */
    Route::post('me',     [AuthController::class, 'me'])->name('me');
});

// UNAUTHORIZED API V1
Route::get('unauthorized', function (){
    // Log::warning('Erro de autenticação da API!', [request()->json()]);
    return response()->json(['success' => false, 'error' => 'Unauthorized'], 401);
})->name('api.unauthorized');


// PROTECTED API V1
Route::group(['middleware' => 'auth:api'], function () {
    // API - V1
    Route::prefix('v1')->name('api.v1.')->group(function () {
        /* Users */
        Route::apiResource('users', UserController::class);
    });
});
