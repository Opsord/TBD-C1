CREATE TABLE Productos(
    IdProducto SERIAL PRIMARY KEY,
    NombreProducto VARCHAR(255),
    DescripcionProducto VARCHAR(400)
);

CREATE TABLE TipoDocumento(
    IdTipoDocumento SERIAL PRIMARY KEY,
    NombreDocumento VARCHAR(255),
    RutDocumento VARCHAR(255),
    TipoDocumento INTEGER
);

CREATE TABLE Comuna (
    IdComuna SERIAL PRIMARY KEY,
    NombreComuna VARCHAR(255),
    ProvinciaComuna VARCHAR(255),
    RegionComuna VARCHAR(255)
);

CREATE TABLE Tienda(
    IdTienda SERIAL PRIMARY KEY,
    NombreTienda VARCHAR(255),
    DireccionTienda VARCHAR(255),
    IdComuna INTEGER,
    FOREIGN KEY (IdComuna) REFERENCES Comuna(IdComuna)
);

CREATE TABLE Venta(
    IdVenta SERIAL PRIMARY KEY,
    FechaVenta DATE,
    MontoVenta NUMERIC,
    IdTipoDocumento INTEGER,
    FOREIGN KEY (IdTipoDocumento) REFERENCES TipoDocumento(IdTipoDocumento),
    IdTienda INTEGER,
    FOREIGN KEY (IdTienda) REFERENCES Tienda(IdTienda)
);

CREATE TABLE Empleado(
    IdEmpleado SERIAL PRIMARY KEY,
    RutEmpleado VARCHAR(12),
    NombreEmpleado VARCHAR(255),
    ApellidoPatEmpleado VARCHAR(255),
    ApellidoMatEmpleado VARCHAR(255),
    TelefonoEmpleado VARCHAR(255),
    CorreoEmpleado VARCHAR(255),
    FechaInicioContrato DATE,
    FechaTerminoContrato DATE,
    HorasExtras NUMERIC,
    IdComuna INTEGER,
    FOREIGN KEY (IdComuna) REFERENCES Comuna(IdComuna),
    IdTienda INTEGER,
    FOREIGN KEY (IdTienda) REFERENCES Tienda(IdTienda),
    CargoEmpleado VARCHAR(255)
);

CREATE TABLE Sueldo (
    IdSueldo SERIAL PRIMARY KEY,
    MontoSueldo NUMERIC,
    FechaPago DATE,
    IdEmpleado INTEGER,
    FOREIGN KEY (IdEmpleado) REFERENCES Empleado(IdEmpleado)
);

CREATE TABLE Vendedor (
    IdVendedor SERIAL PRIMARY KEY,
    ComisionVendedor NUMERIC,
    IdEmpleado INTEGER,
    FOREIGN KEY (IdEmpleado) REFERENCES Empleado(IdEmpleado)
);

CREATE TABLE Producto_Venta (
    IdProductoVenta SERIAL PRIMARY KEY,
    IdProducto INTEGER,
    FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto),
    IdVenta INTEGER,
    FOREIGN KEY (IdVenta) REFERENCES Venta(IdVenta),
    CantidadVendida INTEGER
);

CREATE TABLE Venta_Vendedor (
    IdVentaVendedor SERIAL PRIMARY KEY,
    IdVenta INTEGER,
    FOREIGN KEY (IdVenta) REFERENCES Venta(IdVenta),
    IdVendedor INTEGER,
    FOREIGN KEY (IdVendedor) REFERENCES Vendedor(IdVendedor)
);

CREATE TABLE Tienda_Empleado(
    IdTiendaEmpleado SERIAL PRIMARY KEY,
    IdTienda INTEGER,
    FOREIGN KEY (IdTienda) REFERENCES Tienda(IdTienda),
    IdEmpleado INTEGER,
    FOREIGN KEY (IdEmpleado) REFERENCES Empleado(IdEmpleado)
);

CREATE TABLE Producto_Tienda(
    IdProductoTienda SERIAL PRIMARY KEY,
    IdTienda INTEGER,
    FOREIGN KEY (IdTienda) REFERENCES Tienda(IdTienda),
    IdProducto INTEGER,
    FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto),
    StockEnTienda INTEGER,
    PrecioProducto NUMERIC
);