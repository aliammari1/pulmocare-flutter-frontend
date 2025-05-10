import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/config.dart';
import 'package:medapp/models/patient.dart';
import 'package:medapp/utils/DioClient.dart';
import '../theme/app_theme.dart';

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  _PatientsViewState createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  List<Patient> _patients = [];
  bool _isLoading = true;
  String? _error;
  bool _isDioError = false;
  final Dio dio = DioHttpClient().dio;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _isDioError = false;
      });

      final response = await dio.get('${Config.apiBaseUrl}/patient/list');
      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> data = response.data;
          _patients = data.map((json) => Patient.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load patients: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (e is DioException) {
          _isDioError = true;
          _error = 'No patients available. Please try again later.';
        } else {
          _error = e.toString();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBarWithBackButton(),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      if (_isDioError) {
        // Show an empty state for DioException rather than an error
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AppBarWithBackButton(),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sync_problem,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Patients Available',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _loadPatients,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBarWithBackButton(),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPatients,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_patients.isEmpty) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBarWithBackButton(),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Patients Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your patient list will appear here',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.push('/add-patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Add New Patient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWithBackButton(),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatients,
        child: ListView.builder(
          itemCount: _patients.length + 1, // Add 1 for the button at the bottom
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            if (index == _patients.length) {
              // This is the last item, show the button
              return Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 72), // Added bottom padding for FAB
                child: ElevatedButton(
                  onPressed: () => context.push('/add-patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Add New Patient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }

            final patient = _patients[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor:
                      AppTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                  child: Text(
                    patient.name![0].toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  patient.name!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(patient.email!),
                    if (patient.phone != null) ...[
                      const SizedBox(height: 2),
                      Text(patient.phone!),
                    ],
                  ],
                ),
                onTap: () {
                  // Navigate to patient details
                  context.push('/patient-details', extra: patient);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-patient'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Create a reusable AppBar widget with a back button
class AppBarWithBackButton extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarWithBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.go("/doctor-dashboard"),
      ),
      title: const Text(
        'Patients',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
