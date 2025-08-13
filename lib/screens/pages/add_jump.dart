import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:intl/intl.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';

class AddJumpForm extends StatefulWidget {
  final void Function(JumpLog) onSave;
  final JumpLog? existingJump;
  const AddJumpForm({super.key, required this.onSave,this.existingJump,});

  @override
  State<AddJumpForm> createState() => _AddJumpFormState();
}

class _AddJumpFormState extends State<AddJumpForm> {
  final _formKey = GlobalKey<FormState>();
  final _jumpNumberController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateFormat('dd-MMM-yy').format(DateTime.now()),
  );
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

    if (widget.existingJump != null) {
    final jump = widget.existingJump!;
    _jumpNumberController.text = jump.jumpNumber.toString();
    _dateController.text = jump.date; // Asegúrate que el formato coincida
    _locationController.text = jump.location;
    _aircraftController.text = jump.aircraft;
    _equipmentController.text = jump.equipment;
    _altitudeController.text = jump.altitude.toString();
    _freefallDelayController.text = jump.freefallDelay.toString();
    _totalFreefallController.text = jump.totalFreefall.toString();
    _totalFreefallControllerEdited.text = formatSecondsToHHMMSS(jump.totalFreefall!);
    _jumpTypeNotifier.value = jump.jumpType;
    _weightController.text = jump.weight?.toString() ?? '';
    _ageController.text = jump.age?.toString() ?? '';
    _descriptionController.text = jump.description;
    _signatureController.text = jump.signature;
  } else {
    // Valores por defecto (como tenías antes)
    _dateController.text = DateFormat('dd-MMM-yy').format(DateTime.now());
    _locationController.text = "Cali";
    _aircraftController.text = "PA-32";
    _equipmentController.text = "Sigma-340";
    _altitudeController.text = "8500";
    _freefallDelayController.text = "25";
    _weightController.text = "80";
    _descriptionController.text = "Tandem con ";
    _jumpTypeNotifier.value = 'Tandem';
  }

    _actualizarTotalFreefall();

    _freefallDelayController.addListener(() {
      _actualizarTotalFreefall();
    });
  }

  void _actualizarTotalFreefall() {
    final delay = int.tryParse(_freefallDelayController.text) ?? 0;
    final totalSegundos = lastTotalFreefallNotifier.value + delay;

    // Guardar segundos puros (para DB)
    _totalFreefallController.text = totalSegundos.toString();

    // Guardar tiempo formateado
    _totalFreefallControllerEdited.text = formatSecondsToHHMMSS(totalSegundos);
  }

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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newJump = JumpLog(
        id: widget.existingJump?.id,
        jumpNumber: int.parse(_jumpNumberController.text),
        date: _dateController.text,
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

  final TextStyle _titulos = const TextStyle(
    fontSize: 30,
    letterSpacing: 10.0, // 👉 Aumenta el espacio entre letras
    fontWeight: FontWeight.bold,
  );

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
              ValueListenableBuilder<int>(
                valueListenable: lastJumpNumberNotifier,
                builder:
                    (BuildContext context, int ultimoSalto, Widget? child) {
                       if (widget.existingJump == null){_jumpNumberController.text = (ultimoSalto + 1).toString();} // asignar numero solo si no estamos editando
                      return TextFormField(
                        controller: _jumpNumberController,
                        readOnly: true,
                        //keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Número de salto',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Requerido' : null,
                      );
                    },
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lugar'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _aircraftController,
                decoration: const InputDecoration(labelText: 'Aeronave'),
              ),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(labelText: 'Equipo'),
              ),
              TextFormField(
                controller: _altitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altitud (pies)'),
              ),
              TextFormField(
                controller: _freefallDelayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Retardo (segundos)',
                ),
              ),
              TextFormField(
                controller: _totalFreefallControllerEdited,
                readOnly: true,
                //keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiempo Total de Caida Libre',
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
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
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso'),
              ),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Edad'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _signatureController,
                decoration: const InputDecoration(labelText: 'Firma'),
              ),
              const SizedBox(height: 20),
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
