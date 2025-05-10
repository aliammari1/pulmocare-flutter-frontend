import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medapp/theme/app_theme.dart';

class EmergencyContact {
  final String name;
  final String phone;
  final String? description;
  final IconData icon;
  final Color color;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.description,
    required this.icon,
    required this.color,
  });
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Ambulance',
      phone: '190',
      description: 'For medical emergencies requiring immediate transportation',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    EmergencyContact(
      name: 'Police',
      phone: '197',
      description: 'For safety concerns or to report an incident',
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyContact(
      name: 'Fire Department',
      phone: '198',
      description: 'For fire emergencies or rescue situations',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    EmergencyContact(
      name: 'Emergency Medical Service',
      phone: '190',
      description: 'For urgent medical assistance',
      icon: Icons.medical_services,
      color: Colors.green,
    ),
    EmergencyContact(
      name: 'Civil Protection',
      phone: '198',
      description: 'For natural disasters and major incidents',
      icon: Icons.shield,
      color: Colors.purple,
    ),
    EmergencyContact(
      name: 'Poison Control Center',
      phone: '+216 27 100 290',
      description: 'For toxin ingestion or exposure',
      icon: Icons.science,
      color: Colors.teal,
    ),
  ];

  final List<EmergencyContact> _personalContacts = [];
  bool _isAddingContact = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Show error if can't launch dialer
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call $phone')),
      );
    }
  }

  void _addNewContact() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _personalContacts.add(
          EmergencyContact(
            name: _nameController.text,
            phone: _phoneController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            icon: Icons.person,
            color: Colors.indigo,
          ),
        );

        _nameController.clear();
        _phoneController.clear();
        _descriptionController.clear();
        _isAddingContact = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deletePersonalContact(int index) {
    setState(() {
      _personalContacts.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isAddingContact = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // Emergency Banner
              SliverToBoxAdapter(
                child: _buildEmergencyBanner(),
              ),

              // Section Header - Emergency Numbers
              SliverToBoxAdapter(
                child: _buildSectionHeader('Emergency Services'),
              ),

              // Emergency Services List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildContactCard(_emergencyContacts[index]),
                  childCount: _emergencyContacts.length,
                ),
              ),

              // Section Header - Personal Contacts
              SliverToBoxAdapter(
                child: _buildSectionHeader('Personal Emergency Contacts'),
              ),

              // Personal Contacts List
              _personalContacts.isEmpty
                  ? SliverToBoxAdapter(
                      child: _buildEmptyPersonalContacts(),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPersonalContactCard(
                          _personalContacts[index],
                          index,
                        ),
                        childCount: _personalContacts.length,
                      ),
                    ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // Add Contact Form
          if (_isAddingContact) _buildAddContactForm(),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'For immediate emergencies',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'In case of life-threatening situations, please call emergency services immediately',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _callNumber(contact.phone),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: contact.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  contact.icon,
                  color: contact.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (contact.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _callNumber(contact.phone),
                icon: const Icon(Icons.call),
                label: Text(contact.phone),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalContactCard(EmergencyContact contact, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _callNumber(contact.phone),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: contact.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  contact.icon,
                  color: contact.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (contact.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _callNumber(contact.phone),
                icon: const Icon(Icons.call),
                label: Text(contact.phone),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePersonalContact(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPersonalContacts() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No personal contacts added yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add important contacts like your family doctor or relatives to call in case of emergency',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isAddingContact = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
      ),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Emergency Contact',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _isAddingContact = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addNewContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Save Contact',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
