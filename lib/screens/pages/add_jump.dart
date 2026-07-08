import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:intl/intl.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';

class AddJumpForm extends StatefulWidget {
  
  //data que se recibe de la ruta logbook
  final int index; //0 is skydiving, 1 is basejump.
  final JumpLog? existingJump;
  final void Function(JumpLog) onSave;
  
  const AddJumpForm({super.key, required this.onSave, this.existingJump, required this.index});

  @override
  State<AddJumpForm> createState() => _AddJumpFormState();
}

class _AddJumpFormState extends State<AddJumpForm> {
  final _formKey = GlobalKey<FormState>();

  //. Variable interna para manejar fecha real
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy'); // formato para mostrar mis fechas

  //. Variable para saber si esta inicializando la pagina de edicion:
  bool _inicializando = true;

 

  //. Controladores
  final _jumpNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _aircraftController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _altitudeController = TextEditingController();
  final _freefallDelayController = TextEditingController();
  final _totalFreefallController = TextEditingController();
  final _totalFreefallControllerEdited = TextEditingController();
  final ValueNotifier<String> _jumpTypeNotifier = ValueNotifier('Tandem');
  bool _handyCamBool = false;
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _signatureController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //. Controladores iniciales si es un salto existente en paracaidismo
    if (widget.index == 0 && widget.existingJump != null) {
      
      final jump = widget.existingJump!;//guardamos el salto que estamos editando en una variable de esta funcion.
      
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
      _handyCamBool = jump.handyCam==0?false:true;
      _weightController.text = jump.weight?.toString() ?? '';
      _ageController.text = jump.age?.toString() ?? '';
      _descriptionController.text = jump.description;
      _signatureController.text = jump.signature;

      //Llamamos el callback.
      _freefallDelayController.addListener(_freefallDelayListener1);

      // Asignamos el callback aqui en init porque no se puede antes.
      _freefallDelayListener1 = () {
        if (_inicializando) return;// ✅ evita recalcular en la carga inicial.
        _actualizarTotalFreefall(
          baseHistorica: jump.totalFreefall! - jump.freefallDelay,// argumento de funcion, sirve para mantener base histórica, le resta lo que le habia sumado en la primera insercion del salto
          delay: int.tryParse(_freefallDelayController.text) ?? 0,//argumento de funcion
        );
      };

    } 
    
    //. Valores por defecto skydiving
    else if(widget.index == 0 && widget.existingJump == null){
      _jumpNumberController.text=(lastJumpNumberNotifier.value+1).toString();
      _dateController.text = _dateFormat.format(_selectedDate);
      _locationController.text = "SD Toronto";
      _aircraftController.text = "Caravan";
      _equipmentController.text = "Sigma-340";
      _altitudeController.text = "12000";
      _freefallDelayController.text = "45";
      _weightController.text = "80";
      _descriptionController.text = "Tandem con ";
      _jumpTypeNotifier.value = 'Tandem';
      
      
      _calcularTotalFreefall(); //esta funcion evalua el totalfreefall y lo asigna a su respectivo controller teniendo en cuenta el notifier de totalfreefall


      // Llamamos el callback del listener2
      _freefallDelayController.addListener(_freefallDelayListener2);

      // Asignamos el callback que ya esta declarado.
      _freefallDelayListener2 = () {
      _calcularTotalFreefall();//esta funcion escucha cambios en el delay y recalcula el totalfreefall y lo reasigna al controller teniendo en cuenta el notifier de totalfreefall
      };
    }

    //. Controladores iniciales si es un salto existente en basejump
    if (widget.index == 1 && widget.existingJump != null) {
      
      final jump = widget.existingJump!;//guardamos el salto que estamos editando en una variable de esta funcion.
      
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
      _handyCamBool = jump.handyCam==0?false:true;
      _weightController.text = jump.weight?.toString() ?? '';
      _ageController.text = jump.age?.toString() ?? '';
      _descriptionController.text = jump.description;
      _signatureController.text = jump.signature;

      //Llamamos el listener
      _freefallDelayController.addListener(_freefallDelayListener1);

      // Asignamos el callback que ya esta declarado en la clase.
      _freefallDelayListener1 = () {
        if (_inicializando) return;
        _actualizarTotalFreefall(
          baseHistorica: jump.totalFreefall! - jump.freefallDelay,
          delay: int.tryParse(_freefallDelayController.text) ?? 0,
        );
      };

    }
    
    //. Valores por defecto en BaseJump
    else if(widget.index == 1 && widget.existingJump == null){
      _jumpNumberController.text=(lastJumpNumberBaseNotifier.value+1).toString();
      _dateController.text = _dateFormat.format(_selectedDate);
      _locationController.text = "Linea";
      _aircraftController.text = "B.A.S.E";
      _equipmentController.text = "";
      _altitudeController.text = "";
      _freefallDelayController.text = "";
      _weightController.text = "80";
      _descriptionController.text = "";
      _jumpTypeNotifier.value = 'Belly';
      
      
      _calcularTotalFreefall(); //esta funcion evalua el totalfreefall y lo asigna a su respectivo controller teniendo en cuenta el notifier de totalfreefall

      //llamamos al callback del listener
      _freefallDelayController.addListener(_freefallDelayListener2);

      //Asignamos el callback
      _freefallDelayListener2 = () {
      _calcularTotalFreefall();
      };
    } 

     
  _inicializando = false; // ✅ Terminó de inicializar: ahora sí permite recalcular si hay cambios
    
  }

  //. Funcion para calcular totalfreefall en registro nuevo
  void _calcularTotalFreefall() {
    if (widget.index == 0 ){final delay = int.tryParse(_freefallDelayController.text) ?? 0;
    final totalSegundos = lastTotalFreefallNotifier.value + delay;

    // Guardar segundos puros (para DB)
    _totalFreefallController.text = totalSegundos.toString();

    // Mostrar tiempo formateado
    _totalFreefallControllerEdited.text = formatSecondsToHHMMSS(totalSegundos);}
    else{
      final delay = int.tryParse(_freefallDelayController.text) ?? 0;
      final totalSegundos = lastTotalFreefallBaseNotifier.value + delay;

      // Guardar segundos puros (para DB)
    _totalFreefallController.text = totalSegundos.toString();
    // Mostrar tiempo formateado
    _totalFreefallControllerEdited.text = formatSecondsToHHMMSS(totalSegundos);}
    
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

    _freefallDelayController.removeListener(_freefallDelayListener1);
    _freefallDelayController.removeListener(_freefallDelayListener2);

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
        handyCam: _handyCamBool? 1:0,
        weight: int.tryParse(_weightController.text),
        age: int.tryParse(_ageController.text) ?? 0,
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
//. Tipo de deporte.                            
              Text(widget.index ==0?'SKYDIVING':'BASEJUMP',style: subtitulo,textAlign: TextAlign.center,),
//. Botones de llenado de informacion rapido.              
              Row(children: [
                TextButton(
                  style: _aircraftController.text=='Caravan'? null:buttonStyleNotSelected,
                  onPressed: () => setState((){_aircraftController.text='Caravan';}),
                  child: Text('Caravan')),
                TextButton(
                  style: _aircraftController.text=='C-182'? null:buttonStyleNotSelected,
                  onPressed: () => setState((){_aircraftController.text='C-182';}),
                  child: Text('C-182')),
                TextButton(
                  style: _altitudeController.text=='9000'? null:buttonStyleNotSelected,
                  onPressed: () => setState((){_altitudeController.text='9000';_freefallDelayController.text='25';}),
                  child: Text('9k')),
                TextButton(
                  style: _altitudeController.text=='12000'? null:buttonStyleNotSelected,
                  onPressed: () => setState((){_altitudeController.text='12000';_freefallDelayController.text='45';}),
                  child: Text('12k')),
                TextButton(
                  style: _altitudeController.text=='15000'? null:buttonStyleNotSelected,
                  onPressed: () => setState((){_altitudeController.text='15000';_freefallDelayController.text='55';}),
                  child: Text('15k')),
              ],),
              Row(children: [
//. Numero de salto.              
                Flexible(
                  child: TextFormField(
                    controller: _jumpNumberController,
                    readOnly: true, // Si es un salto editado al cargar datos de ruta se asigna el numero de salto.
                    decoration: const InputDecoration(labelText: 'Número de salto',),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                ),
//. Fecha.
                Flexible(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: _dateController.text == _dateFormat.format(DateTime.now()) ? 'Hoy' : 'Fecha',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                ),
              ],),
              Row(
                children: [
//. Lugar.
                  Flexible(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Lugar'),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
//. Aeronave.              
                  Flexible(
                    child: TextFormField(
                      controller: _aircraftController,
                      decoration: const InputDecoration(labelText: 'Aeronave'),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],),
              Row(
                children: [
//. Equipo.              
                  Flexible(
                    child: TextFormField(
                      controller: _equipmentController,
                      decoration: const InputDecoration(labelText: 'Equipo'),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
//. Altitud.              
                  Flexible(
                    child: TextFormField(
                      controller: _altitudeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Altitud (pies)'),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
//. Delay.              
                  Flexible(
                    child: TextFormField(
                      controller: _freefallDelayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Retardo (segundos)',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
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
              Row(
                children: [
                  ValueListenableBuilder(
                  valueListenable: _jumpTypeNotifier,
                  builder: (BuildContext context, String jumpT, Widget? child) {
                    return Flexible(
                      child: DropdownButtonFormField(
                        initialValue: jumpT,
                        onChanged: (newValue) {
                          _jumpTypeNotifier.value = newValue!;
                        },
                        items: widget.index == 0 
                          ? jumpTypeList.map((String item) {
                            return DropdownMenuItem(value: item, child: Text(item));}).toList()
                          : jumpTypeListInBase.map((String item) {
                            return DropdownMenuItem(value: item, child: Text(item));}).toList(),
                        decoration: InputDecoration(labelText: 'Jump Type'),
                      ),
                    );
                  },
                  ),
                  Flexible(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: BorderSide(width: 5)),
                    child: 
                      SwitchListTile.adaptive(
                        title: Text('HC?'),
                        value: _handyCamBool,
                        onChanged: (isHandyCam) => setState((){_handyCamBool=isHandyCam;}),
                        visualDensity: VisualDensity.compact,
                      ),)
                ),

                ],
              ),
//. Peso.              
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Peso en kg'),
                  ),
                ),
                TextButton(onPressed: () {
                  _weightController.text = ((int.tryParse(_weightController.text) ?? 0)/2.2).round().toString();
                  },
                  style: TextButton.styleFrom(side: BorderSide(width: 5),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('↑↓ Convert Lbs to Kg'),
                ),
              ],),
//. Edad y HandyCam.              
              Row(children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Edad'),
                  ),
                ),
                
              ],),
//. Descripcion.              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
//. Signature.              
              TextFormField(
                controller: _signatureController,
                decoration: const InputDecoration(labelText: 'Firma'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
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

  //!                           CALLBACKS


   //. Callbacks de listeners para tenerlos como referencia
  VoidCallback _freefallDelayListener1 = (){};
  VoidCallback _freefallDelayListener2 = (){};

  
}
