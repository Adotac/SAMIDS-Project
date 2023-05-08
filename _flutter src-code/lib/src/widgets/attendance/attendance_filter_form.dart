import 'package:flutter/material.dart';
import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/attendance_search_params.dart';


class FilterForm extends StatefulWidget {
  final AttendanceSearchParams searchParams;

  FilterForm(this.searchParams);

  @override
  _FilterFormState createState() => _FilterFormState();
}

class _FilterFormState extends State<FilterForm> {
  final _formKey = GlobalKey<FormState>();
  Remarks? _selectedRemarks;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DateTimeFormField(
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
                initialValue: widget.searchParams.date,
                onSaved: (value) => value!= null ? widget.searchParams.date = value : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Room',
                ),
                initialValue: widget.searchParams.room,
                onSaved: (value) => value!= null ? widget.searchParams.room = value: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Student No.',
                ),
                initialValue: widget.searchParams.studentNo?.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) => value!= null ?widget.searchParams.studentNo = int.tryParse(value ?? '') : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Faculty No.',
                ),
                initialValue: widget.searchParams.facultyNo?.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) => value != null ? widget.searchParams.facultyNo = int.tryParse(value ?? '') : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<Remarks>(
                decoration: InputDecoration(
                  labelText: 'Remarks',
                ),
                value: _selectedRemarks ?? widget.searchParams.remarks,
                items: Remarks.values.map((remarks) {
                  return DropdownMenuItem<Remarks>(
                    value: remarks,
                    child: Text(remarks.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRemarks = value;
                  });
                },
                onSaved: (value) => value != null ? widget.searchParams.remarks = value : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Subject Id',
                ),
                initialValue: widget.searchParams.subjectId?.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) => value!= null ? widget.searchParams.subjectId = int.tryParse(value ?? '') : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Sched Id',
                ),
                initialValue: widget.searchParams.schedId?.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) => value!= null ? widget.searchParams.schedId = int.tryParse(value ?? '') : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DateTimeFormField(
                decoration: InputDecoration(
                  labelText: 'From Date',
                ),
                initialValue: widget.searchParams.fromDate,
                onSaved: (value) => value != null ? widget.searchParams.fromDate = value : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DateTimeFormField(
                decoration: InputDecoration(
                  labelText: 'To Date',
                ),
                initialValue: widget.searchParams.toDate,
                onSaved: (value) => value != null ? widget.searchParams.toDate = value : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateTimeFormField extends FormField<DateTime> {
  DateTimeFormField({
    Key? key,
    FormFieldSetter<DateTime>? onSaved,
    FormFieldValidator<DateTime>? validator,
    DateTime? initialValue,
    InputDecoration decoration = const InputDecoration(),
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<DateTime> state) {
            return InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: state.context,
                  initialDate: state.value ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != state.value) {
                  state.didChange(picked);
                  print('DateTimeFormField value changed: $picked');
                  if (onSaved != null) {
                    onSaved(picked);
                    print('DateTimeFormField onSaved called');
                  }
                }
              },
              child: InputDecorator(
                decoration: decoration.copyWith(errorText: state.hasError ? state.errorText : null),
                child: Text(state.value != null ? state.value.toString() : ''),
              ),
            );
          },
        );
}
//With these changes, you should be able to see whether the onSaved callback is actually being called when the value changes.







