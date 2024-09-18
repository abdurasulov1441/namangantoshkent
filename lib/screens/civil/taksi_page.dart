import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namangantoshkent/style/app_colors.dart';
import 'package:namangantoshkent/style/app_style.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage({super.key});

  @override
  _TaxiPageState createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> {
  String fromLocation = 'Namangan';
  String toLocation = 'Toshkent';

  final TextEditingController _phoneController = TextEditingController();

  final List<String> _periodOptions = [
    'Tanlanmadi',
    'Hoziroq',
    'Bugun',
    'Ertaga',
    'Boshqa vaqt'
  ];
  final List<String> _peopleOptions = ['Tanlanmadi', '1', '2', '3', '4'];

  String _selectedPeriod = 'Tanlanmadi';
  String _selectedPeople = 'Tanlanmadi';
  DateTime? _selectedDateTime;

  void _swapLocations() {
    setState(() {
      final temp = fromLocation;
      fromLocation = toLocation;
      toLocation = temp;
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedPeriod == 'Bugun'
              ? DateTime.now().year
              : DateTime.now().year,
          _selectedPeriod == 'Bugun'
              ? DateTime.now().month
              : DateTime.now().month,
          _selectedPeriod == 'Bugun'
              ? DateTime.now().day
              : DateTime.now().day + 1,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitData() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty ||
        _selectedPeriod == 'Tanlanmadi' ||
        _selectedPeople == 'Tanlanmadi' ||
        (_selectedPeriod == 'Boshqa vaqt' && _selectedDateTime == null)) {
      _showSnackBar('Iltimos, barcha maydonlarni to\'ldiring.');
      return;
    }

    final orderData = {
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'phoneNumber': phoneNumber,
      'peopleCount': int.parse(_selectedPeople),
      'orderTime': _selectedDateTime != null
          ? Timestamp.fromDate(_selectedDateTime!)
          : Timestamp.fromDate(DateTime.now()),
      'status': 'pending',
      'orderType': 'taksi', // Buyurtma turi qo'shildi
      'driverId': null,
      'driverPhoneNumber': null,
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);

    _showSnackBar('Ma\'lumotlar yuborildi!');

    setState(() {
      _phoneController.clear();
      _selectedPeriod = 'Tanlanmadi';
      _selectedPeople = 'Tanlanmadi';
      _selectedDateTime = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationContainer('Qayerdan', fromLocation),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _swapLocations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxi,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(
                Icons.swap_calls,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildLocationContainer('Qayerga', toLocation),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Vaqtni tanlang',
              value: _selectedPeriod,
              items: _periodOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue!;
                  _selectedDateTime = null;
                });
                if (_selectedPeriod == 'Boshqa vaqt') {
                  _pickDateTime();
                } else if (_selectedPeriod == 'Bugun' ||
                    _selectedPeriod == 'Ertaga') {
                  _pickTime();
                }
              },
            ),
            if ((_selectedPeriod == 'Bugun' ||
                    _selectedPeriod == 'Ertaga' ||
                    _selectedPeriod == 'Boshqa vaqt') &&
                _selectedDateTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _buildDateTimeDisplay(),
              ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Odamlar soni',
              value: _selectedPeople,
              items: _peopleOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeople = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _phoneController,
              hintText: 'Telefon raqamingizni kiriting',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                backgroundColor: AppColors.taxi,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(
                'Yuborish',
                style: AppStyle.fontStyle.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 150,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLocationContainer(String label, String location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.taxi,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.taxi.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '$label: $location',
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeDisplay() {
    final formattedDate =
        DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tanlangan vaqt:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          formattedDate,
          style: const TextStyle(fontSize: 16),
        ),
        if (_selectedPeriod == 'Boshqa vaqt')
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppColors.taxi,
            ),
            onPressed: _pickDateTime,
          )
        else
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppColors.taxi,
            ),
            onPressed: _pickTime,
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.phone,
          color: AppColors.taxi,
        ),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
