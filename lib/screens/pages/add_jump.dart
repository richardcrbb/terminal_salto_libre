import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:intl/intl.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';

class AddJumpForm extends StatefulWidget {
  final void Function(JumpLog) onSave;
  const AddJumpForm({super.key, required this.onSave});

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
  final ValueNotifier<String> _jumpTypeNotifier = ValueNotifier('Tandem');
  final _weightController = TextEditingController(text: '80');
  final List<String> _jumpTypeList = [
    'Tandem',
    'AFF',
    'Camera',
    'Coach',
    'Fun Jump',
  ];
  final _descriptionController = TextEditingController(text: "Tandem con ");
  final _signatureController = TextEditingController();

  @override
  void dispose() {
    _jumpNumberController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _aircraftController.dispose();
    _equipmentController.dispose();
    _altitudeController.dispose();
    _freefallDelayController.dispose();
    _descriptionController.dispose();
    _signatureController.dispose();
    _jumpTypeNotifier.dispose();
    _weightController.dispose();
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

  @override
  void initState() {
    super.initState();
    _loadNextJumpNumber(); 
  }

  Future<void> _loadNextJumpNumber() async {
  final lastNumber = await JumpLogDatabase.getLastJumpNumber();
  setState(() {
    _jumpNumberController.text = (lastNumber + 1).toString();
  });
}

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newJump = JumpLog(
        jumpNumber: int.parse(_jumpNumberController.text),
        date: _dateController.text,
        location: _locationController.text,
        aircraft: _aircraftController.text,
        equipment: _equipmentController.text,
        altitude: int.parse(_altitudeController.text),
        freefallDelay: int.parse(_freefallDelayController.text),
        jumpType: _jumpTypeNotifier.value,
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
              TextFormField(
                controller: _jumpNumberController,
                readOnly: true,
                //keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número de salto'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
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
              ValueListenableBuilder(
                valueListenable: _jumpTypeNotifier,
                builder: (BuildContext context, String jumpT, Widget? child) {
                  return DropdownButtonFormField(
                    value: jumpT,
                    onChanged: (newValue) {
                      _jumpTypeNotifier.value = newValue!;
                    },
                    items: _jumpTypeList.map((String item) {
                      return DropdownMenuItem(value: item ,child: Text(item),);
                    },).toList(),
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
