import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kpp_lab/features/auth/screens/login_screen.dart';
import 'package:kpp_lab/features/journal/screens/add_workout_screen.dart';
import 'package:kpp_lab/features/profile/screens/profile_screen.dart';
import 'package:kpp_lab/features/journal/cubit/workout_cubit.dart';
import 'package:kpp_lab/features/journal/cubit/workout_state.dart';
import 'package:kpp_lab/features/journal/screens/workout_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpp_lab/features/progress/cubit/progress_cubit.dart';
import 'package:kpp_lab/features/progress/cubit/progress_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? 'Користувач';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FitTrack'),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
            child: Tooltip(
              message: displayName,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person) : null,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Вийти',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Журнал', icon: Icon(Icons.fitness_center)),
              Tab(text: 'Прогрес', icon: Icon(Icons.show_chart)),
            ],
          ),
        ),
        body: const TabBarView(children: [JournalTabContent(), ProgressTabContent()]),
      ),
    );
  }
}

class JournalTabContent extends StatelessWidget {
  const JournalTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
          );
        },
        label: const Text('Тренування'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkoutError) {
            return Center(child: Text(state.message));
          } else if (state is WorkoutLoaded) {
            if (state.workouts.isEmpty) {
              return const Center(child: Text("Історія порожня. Почніть тренування!"));
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<WorkoutCubit>().subscribeToWorkouts();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.workouts.length,
                itemBuilder: (context, index) {
                  final workout = state.workouts[index];
                  final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(workout.date);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetailScreen(workout: workout),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  workout.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dateStr,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const Divider(),
                            Text(
                              'Вправ: ${workout.exercises.length} • Тоннаж: ${workout.totalVolume} кг',
                              style: const TextStyle(
                                color: Color(0xFF4A90E2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ProgressTabContent extends StatelessWidget {
  const ProgressTabContent({super.key});

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (context.mounted) {
        context.read<ProgressCubit>().uploadPhoto(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Завантаження фото...')),
        );
      }
    }
  }

void _confirmDelete(BuildContext context, String photoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити фото?'),
        content: const Text('Цю дію не можна скасувати.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ні'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProgressCubit>().deletePhoto(photoId);
              Navigator.of(ctx).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Фото видалено')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Мій Прогрес', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(child: Text('[ Тут буде графік ваги ]')),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Галерея форми', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => _pickAndUploadPhoto(context),
                  icon: const Icon(Icons.add_a_photo, color: Color(0xFF4A90E2)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ГАЛЕРЕЯ
            Expanded(
              child: BlocBuilder<ProgressCubit, ProgressState>(
                builder: (context, state) {
                  if (state is ProgressLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProgressError) {
                    return Center(child: Text(state.message));
                  } else if (state is ProgressLoaded) {
                    if (state.photos.isEmpty) {
                      return const Center(child: Text('Немає фото. Додайте перше!'));
                    }
                    
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: state.photos.length,
                      itemBuilder: (context, index) {
                        final photo = state.photos[index];
                        
                        return GestureDetector(
                          onLongPress: () => _confirmDelete(context, photo.id),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  photo.imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (ctx, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(color: Colors.grey[200]);
                                  },
                                  errorBuilder: (context, error, stackTrace) => 
                                      const Center(child: Icon(Icons.error)),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}