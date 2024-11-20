// VIKINGOS

class Vikingo {
  var property casta
  var oro = 0
  
  method tieneArmas()
  method esProductivo()

  method puedeExpedicionar() = self.esProductivo() && casta.loPermite(self)

  method escalarSocialmente() {
    casta.convertir(self)
  }

  method recibirBonificacion()

  method subirseA(expedicion) {
    if (self.puedeExpedicionar())
      expedicion.subirVikingo(self)
    else
      throw new DomainException(message = "no se puede subir")
  }

  method ganarOro(oroNuevo) {
    oro += oroNuevo
  }

  method cobrarVida() {}
}

class Soldado inherits Vikingo {
  var property armas
  var property vidasCobradas

  override method tieneArmas() = armas > 0

  override method esProductivo() = vidasCobradas > 20 && self.tieneArmas()

  override method recibirBonificacion() {
    armas += 10
  }

  override method cobrarVida() {
    vidasCobradas += 1
  }
}

class Granjero inherits Vikingo {
  var hijos
  var hectareas

  override method esProductivo() = hectareas >= 2 * hijos

  override method recibirBonificacion() {
    hijos += 2
    hectareas += 2
  }
}

class Casta {
  const castaSuperior

  method loPermite(vikingo)

  method convetir(vikingo) {
    vikingo.casta(castaSuperior)
  }
}

object jarl inherits Casta(castaSuperior = karl) {
  override method loPermite(vikingo) = !(vikingo.tieneArmas())

  method convertir(vikingo) {
    vikingo.casta(castaSuperior)
    vikingo.recibirBonificacion()
  }
}

object karl inherits Casta(castaSuperior = thrall) {
  override method loPermite(vikingo) = true
}

object thrall inherits Casta(castaSuperior = self) {
  override method loPermite(vikingo) = true
}


// EXPEDICIONES

class Expedicion {
  const regionesInvadidas = []
  const property vikingos = []

  method valeLaPena() = regionesInvadidas.all({region => region.valeInvadir(self)})

  method subirVikingo(vikingo) {
    vikingos.add(vikingo)
  }

  method botinObtenido() = regionesInvadidas.sum({region => region.botin()})

  method repartirBotin() {
    vikingos.forEach({vikingo => vikingo.ganarOro(self.botinObtenido() / vikingos.size())})
  }

  method realizar() {
    self.repartirBotin()
    regionesInvadidas.forEach({region => region.serInvadido(self)})
  }
}


// REGIONES

class Capital {
  const factorDeRiqueza

  method defensoresDerrotados(expedicion) = expedicion.vikingos().size()
  method botin(expedicion) = self.defensoresDerrotados(expedicion) * factorDeRiqueza

  method valeInvadir(expedicion) = self.botin(expedicion) >= expedicion.vikingos().size() * 3

  method serInvadido(expedicion) {
    expedicion.vikingos().forEach({vikingo => vikingo.cobrarVida()})
  }
}

class Aldea {
  var crucifijos

  method botin(expedicion) = crucifijos

  method valeInvadir(expedicion) = self.botin(expedicion) >= 15

  method serInvadido() {
    crucifijos = 0
  }
}

class AldeaAmurallada inherits Aldea {
  const minimo

  override method valeInvadir(expedicion) = super(expedicion) && expedicion.vikingos().size() >= minimo
}