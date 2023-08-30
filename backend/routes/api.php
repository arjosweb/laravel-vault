<?php

use App\Http\Controllers\ReviewController;
use App\Http\Controllers\SpecialistController;
use Illuminate\Http\Request;
use Illuminate\Routing\Middleware\ThrottleRequests;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::get('', function () {
    return response()->json(['status_code' => 200]);
});

Route::post('/login', function (Request $request) {
    if (Auth::attempt($request->only(['email', 'password'])) === false) {
        return response()->json(['status_code' => 401], 401);
    }

    return response()->json(['status_code' => 200]);
});

Route::middleware('auth')->group(function () {
    Route::get('/specialists/highest_rated/{limit?}', [SpecialistController::class, 'highestRated']);
    Route::apiResource('/specialists', SpecialistController::class);
    Route::apiResource('specialists.reviews', ReviewController::class);
});

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
Route::get('/test', fn () => 'Ok')
    ->withoutMiddleware(ThrottleRequests::class . ':api');

