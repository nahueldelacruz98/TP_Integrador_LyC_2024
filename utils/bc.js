function binarycount(aux, condicion) {
    let count = 0;
    let pot = 1;
    let flag = 1;

    // Encontrar la potencia de 10 más grande menor o igual al número
    while (pot <= aux) {
        pot *= 10;
    }

    // Procesar cada dígito
    while (pot > 1) {
        pot /= 10;
        let res = aux % pot; // Obtener el dígito más significativo
        aux = aux - pot;        // Reducir el número
        if (res != 0 && res != 1 ) {          // Comprobar la condición para el dígito
            flag = 0;
        }
    }

    if(flag == 1) {
        count++;
    }

    return count;
}

// Ejemplo de uso:
// Condición: contar dígitos mayores a 5
let condicion = (digito) => digito > 5;
let resultado = binarycount(120, condicion);
console.log("Resultado:", resultado);