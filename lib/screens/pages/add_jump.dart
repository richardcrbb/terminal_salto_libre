import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:intl/intl.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';

class AddJumpForm extends StatefulWidget {
  
  //data que se recibe de la ruta logbook
  final JumpLog? existingJump;
  final void Function(JumpLog) onSave;
  
  const AddJumpForm({super.key, required this.onSave, this.existingJump});

  @override
  State<AddJumpForm> createState() => _AddJumpFormState();
}

class _AddJumpFormState extends State<AddJumpForm> {
  final _formKey = GlobalKey<FormState>();

  //. Variable interna para manejar fecha real
  DateTime _selectedDate = DateTime.now();
  final _dateFormat = DateFormat('dd-MMM-yyyy'); // formato para mostrar mis fechas

  //. Variable para saber si esta inicializando la pagina de edicion:
  bool _inicializando = true;

  //. Controladores
  final _jumpNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController(text: "Cali");
  final _aircraftController = TextEditingController(text: "PA-32");
  final _equipmentController = TextEditingController(text: "Sigma-340");
  final _altitudeController = TextEditingController(text: "8500");
  final _freefallDelayController = TextEditingController(text: "25");
  final _totalFreefallController = TextEditingController();
  final _totalFreefallControllerEdited = TextEditingController();
  final ValueNotifier<String> _jumpTypeNotifier = ValueNotifier('Tandem');
  final _weightController = TextEditingController(text: '80');
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController(text: "Tandem con ");
  final _signatureController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //. Controladores iniciales si es un salto existente
    if (widget.existingJump != null) {
      
      final jump = widget.existingJump!;//guardamos el salto que estamos editando en una variable de esta clase.
      
      _selectedDate = DateTime.parse(jump.date); // guarda fecha que viene del salto que estamos editando
      
      _jumpNumberController.text = jump.jumpNumber.toString();
      _dateController.text = _dateFormat.format(_selectedDate);
      _locationController.text = jump.location;
      _aircraftController.text = jump.aircraft;
      _equipmentController.text = jump.equipment;
      _altitudeController.text = jump.altitude.toString();
      _freefallDelayController.text = jump.freefallDelay.toString();
      _totalFreefallController.text = jump.totalFreefall.toString();
      _totalFreefallControllerEdited.text = formatSecondsToHHMMSS(jump.totalFreefall!,);
      _jumpTypeNotifier.value = jump.jumpType;
      _weightController.text = jump.weight?.toString() ?? '';
      _ageController.text = jump.age?.toString() ?? '';
      _descriptionController.text = jump.description;
      _signatureController.text = jump.signature;

      // Listener que solo recalcula si cambia el delay
      _freefallDelayController.addListener(() {
         if (_inicializando) return; // ✅ evita recalcular en la carga inicial.
        _actualizarTotalFreefall(
          baseHistorica: jump.totalFreefall! - jump.freefallDelay,// argumento de funcion, sirve para mantener base histórica, le resta lo que le habia sumado en la primera insercion del salto
          delay: int.tryParse(_freefallDelayController.text) ?? 0, //argumento de funcion
        );
      });

    } 
    
    //. Valores por defecto (como tenías antes)
    else {
      _dateController.text = _dateFormat.format(_selectedDate);
      _locationController.text = "Cali";
      _aircraftController.text = "PA-32";
      _equipmentController.text = "Sigma-340";
      _altitudeController.text = "8500";
      _freefallDelayController.text = "25";
      _weightController.text = "80";
      _descriptionController.text = "Tandem con ";
      _jumpTypeNotifier.value = 'Tandem';
      
      
      _calcularTotalFreefall(); //esta funcion evalua el totalfreefall y lo asigna a su respectivo controller teniendo en cuenta el notifier de totalfreefall

      _freefallDelayController.addListener(() {
        _calcularTotalFreefall();
      }); //esta funcion escucha cambios en el delay y recalcula el totalfreefall y lo reasigna al controller teniendo en cuenta el notifier de totalfreefall
    }

     
  _inicializando = false; // ✅ Terminó de inicializar: ahora sí permite recalcular si hay cambios
    
  }

  //. Funcion para calcular totalfreefall en registro nuevo
  void _calcularTotalFreefall() {
    final delay = int.tryParse(_freefallDelayController.text) ?? 0;
    final totalSegundos = lastTotalFreefallNotifier.value + delay;

    // Guardar segundos puros (para DB)
    _totalFreefallController.text = totalSegundos.toString();

    // Mostrar tiempo formateado
    _totalFreefallControllerEdited.text = formatSecondsToHHMMSS(totalSegundos);
  }

  
  
  //. Funcion para actualizar totalfreefall en registro editado si fuera necesario
  void _actualizarTotalFreefall({required int baseHistorica, required int delay}) {
  final totalSegundos = baseHistorica + delay;
  _totalFreefallController.text = totalSegundos.toString();
  _totalFreefallControllerEdited.text = formatSecondsToHHMMSS(totalSegundos);
  }



//. Metodo para limpiar memoria cache.
  @override
  void dispose() {
    _jumpNumberController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _aircraftController.dispose();
    _equipmentController.dispose();
    _altitudeController.dispose();
    _freefallDelayController.dispose();
    _totalFreefallController.dispose();
    _totalFreefallControllerEdited.dispose();
    _descriptionController.dispose();
    _signatureController.dispose();
    _jumpTypeNotifier.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

//. Funcion para seleccionar y formatear fecha
    Future<void> _selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1990),
        lastDate: DateTime(2100),
      );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _dateFormat.format(picked);
      });
    }
    }

//. Funcion para crear objeto jumplog, nuevo o editado y llama al callback para guardarlo en db
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newJump = JumpLog(
        id: widget.existingJump?.id,
        jumpNumber: int.parse(_jumpNumberController.text),
        date: _selectedDate.toIso8601String(), // formato seguro para DB
        location: _locationController.text,
        aircraft: _aircraftController.text,
        equipment: _equipmentController.text,
        altitude: int.parse(_altitudeController.text),
        freefallDelay: int.parse(_freefallDelayController.text),
        totalFreefall: int.parse(_totalFreefallController.text),
        jumpType: _jumpTypeNotifier.value,
        weight: int.tryParse(_weightController.text),
        age: int.tryParse(_ageController.text),
        description: _descriptionController.text,
        signature: _signatureController.text,
      );

      widget.onSave(newJump);

      Navigator.pop(context);
    }
  }

//. Formato de texto privado a esta clase.
  final TextStyle _titulos = const TextStyle(
    fontSize: 30,
    letterSpacing: 10.0, // 👉 Aumenta el espacio entre letras
    fontWeight: FontWeight.bold,
  );

//. widgetTree de esta ruta.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADD JUMP"),
        titleTextStyle: _titulos,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
//. Numero de salto.              
              ValueListenableBuilder<int>(
                valueListenable: lastJumpNumberNotifier,
                builder:
                    (BuildContext context, int ultimoSalto, Widget? child) {
                      if (widget.existingJump == null) {
                        _jumpNumberController.text = (ultimoSalto + 1)
                            .toString();
                      } // asigna numero de salto, solo si un salto nuevo
                      return TextFormField(
                        controller: _jumpNumberController,
                        readOnly: true, // Si es un salto editado al cargar datos de ruta se asigna el numero de salto.
                        decoration: const InputDecoration(
                          labelText: 'Número de salto',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Requerido' : null,
                      );
                    },
              ),
//. Fecha.
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
//. Lugar.
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lugar'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
//. Aeronave.              
              TextFormField(
                controller: _aircraftController,
                decoration: const InputDecoration(labelText: 'Aeronave'),
              ),
//. Equipo.              
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(labelText: 'Equipo'),
              ),
//. Altitud.              
              TextFormField(
                controller: _altitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altitud (pies)'),
              ),
//. Delay.              
              TextFormField(
                controller: _freefallDelayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Retardo (segundos)',
                ),
              ),
//. TotalFreefall.              
              TextFormField(
                controller: _totalFreefallControllerEdited,
                readOnly: true,
                //keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiempo Total de Caida Libre',
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
//. Tipo/Categoria.              
              ValueListenableBuilder(
                valueListenable: _jumpTypeNotifier,
                builder: (BuildContext context, String jumpT, Widget? child) {
                  return DropdownButtonFormField(
                    value: jumpT,
                    onChanged: (newValue) {
                      _jumpTypeNotifier.value = newValue!;
                    },
                    items: jumpTypeList.map((String item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Jump Type'),
                  );
                },
              ),
//. Peso.              
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso'),
              ),
//. Edad.              
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Edad'),
              ),
//. Descripcion.              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
//. Signature.              
              TextFormField(
                controller: _signatureController,
                decoration: const InputDecoration(labelText: 'Firma'),
              ),
              const SizedBox(height: 20),
//. Boton de guardado.              
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text("Guardar salto"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
