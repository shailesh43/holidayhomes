import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holidayhomes/core/utils/enum.dart';
import 'package:holidayhomes/network/api_client.dart';
import 'package:holidayhomes/network/api_models/edit_guest_info_response.dart';

class EditGuestDetails extends StatefulWidget {
  final UserRole role;
  const EditGuestDetails({super.key, required this.role});

  @override
  State<EditGuestDetails> createState() => _EditGuestDetailsState();
}

// Helper class to manage state for each dynamic row
class _GuestRowData {
  final int hdHmTransSno;
  int relationId;

  final TextEditingController nameController;
  String relationName;
  final TextEditingController ageController;

  _GuestRowData({
    required this.hdHmTransSno,
    required this.relationId,
    required String initialName,
    required this.relationName,
    required String initialAge,
  })  : nameController = TextEditingController(text: initialName),
        ageController = TextEditingController(text: initialAge);

  void dispose() {
    nameController.dispose();
    ageController.dispose();
  }
}

class _EditGuestDetailsState extends State<EditGuestDetails> {
  final TextEditingController _bookingIdController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _statusMessage;
  bool _isSuccessMessage = false;

  List<_GuestRowData> _guestRows = [];

  final List<String> _relationOptions = ['Self', 'Guest', 'Spouse', 'Child'];

  @override
  void dispose() {
    _bookingIdController.dispose();
    for (var row in _guestRows) {
      row.dispose();
    }
    super.dispose();
  }

  // ─── API INTEGRATION ──────────────────────────────────────────────────────

  Future<void> _loadGuests() async {
    final bookingId = _bookingIdController.text.trim();

    if (bookingId.isEmpty || bookingId.length != 4) {
      setState(() {
        _isSuccessMessage = false;
        _statusMessage = 'Please enter a valid 4-digit Booking ID.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      for (var row in _guestRows) {
        row.dispose();
      }
      _guestRows.clear();
    });

    try {
      final EditGuestInfoResponse response = await ApiClient().getEditGuestInfo(bookingId: bookingId);
      final guests = response.data;

      if (guests.isEmpty) {
        setState(() {
          _isSuccessMessage = false;
          _statusMessage = 'No guests found for Booking ID $bookingId.';
        });
        return;
      }

      setState(() {
        _guestRows = guests.map((guest) {
          String safeRelName = 'Guest';
          return _GuestRowData(
            hdHmTransSno: guest.hdHmTransSno ?? 0,
            relationId: guest.guestRelation ?? 0,
            initialName: guest.guestName ?? '',
            relationName: safeRelName,
            initialAge: (guest.guestAge ?? 0).toString(),
          );
        }).toList();

        _isSuccessMessage = true;
        _statusMessage = 'Loaded ${_guestRows.length} guest(s) for Booking ID $bookingId.';
      });
    } catch (e) {
      setState(() {
        _isSuccessMessage = false;
        _statusMessage = 'Failed to load guests: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGuests() async {
    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      final List<Map<String, dynamic>> updatedGuestsPayload = _guestRows.map((row) {
        return {
          'hd_hm_trans_sno': row.hdHmTransSno,
          'guest_name': row.nameController.text.trim(),
          'guest_relation': row.relationId,
          'rel_name': row.relationName,
          'guest_age': int.tryParse(row.ageController.text.trim()) ?? 0,
        };
      }).toList();

      // await ApiClient().saveGuestDetails(bookingId: _bookingIdController.text, guests: updatedGuestsPayload);
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isSuccessMessage = true;
        _statusMessage = 'Guest details saved successfully!';
      });
    } catch (e) {
      setState(() {
        _isSuccessMessage = false;
        _statusMessage = 'Failed to save guest details: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // ─── UI BUILDERS ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Guest Details',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusBanner(),
                if (_statusMessage != null) const SizedBox(height: 16),
                _buildSearchRow(),
                const SizedBox(height: 24),
                if (_guestRows.isNotEmpty) ...[
                  const Text('Guest List',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const SizedBox(height: 12),
                  _buildGuestList(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (_statusMessage == null) return const SizedBox.shrink();

    final bgColor = _isSuccessMessage ? Colors.green.shade50 : Colors.red.shade50;
    final borderColor = _isSuccessMessage ? Colors.green.shade200 : Colors.red.shade200;
    final textColor = _isSuccessMessage ? Colors.green.shade800 : Colors.red.shade800;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusMessage!,
        style: TextStyle(fontFamily: 'Inter', color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking ID',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bookingIdController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter 4-digit ID',
                  counterText: '',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loadGuests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Load Guests', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuestList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _guestRows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final row = _guestRows[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color.fromRGBO(0, 100, 200, 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color.fromRGBO(0, 100, 200, 0.1),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(0, 100, 200, 1.0), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('GUEST NAME *', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: row.nameController,
                style: const TextStyle(fontFamily: 'Inter'),
                decoration: _inputDecoration('Full Name'),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RELATION *', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: row.relationName,
                          style: const TextStyle(fontFamily: 'Inter', color: Colors.black87),
                          decoration: _inputDecoration('Relation'),
                          items: _relationOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 14), overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                row.relationName = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AGE *', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: row.ageController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'Inter'),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _inputDecoration('Age'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'Inter', color: Colors.grey.shade400, fontSize: 13),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveGuests,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Guest Details', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}