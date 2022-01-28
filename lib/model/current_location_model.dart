class CurrentLocation {
    CurrentLocation({
        this.dispositivoId,
        this.usuarioId,
        this.latitud,
        this.longitud,
        this.date,
    });

    String dispositivoId;
    String usuarioId;
    double latitud;
    double longitud;
    DateTime date;

    Map<String, dynamic> toJson() => {
        "dispositivoId": dispositivoId != null ? dispositivoId : null,
        "usuarioId": usuarioId != null ? usuarioId : null,
        "latitud": latitud != null ? latitud : null,
        "longitud": longitud != null ? longitud : null,
        "date": date != null ? date.toIso8601String() : null,
    };
}
