class CurrentLocation {
    CurrentLocation({
        this.dispositivoId,
        this.usuarioId,
        this.latitud,
        this.longitud,
        this.fecha,
    });

    String dispositivoId;
    String usuarioId;
    double latitud;
    double longitud;
    DateTime fecha;

    Map<String, dynamic> toJson() => {
        "dispositivoId": dispositivoId != null ? dispositivoId : null,
        "usuarioId": usuarioId != null ? usuarioId : null,
        "latitud": latitud != null ? latitud : null,
        "longitud": longitud != null ? longitud : null,
        "fecha": fecha != null ? fecha.toIso8601String() : null,
    };
}
