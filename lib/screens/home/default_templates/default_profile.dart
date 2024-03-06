import 'package:flutter/material.dart';
import 'package:atlas/services/database.dart'; // Ensure this path is correct for your DatabaseService
import 'package:atlas/screens/home/profile_page/settings_page.dart';
import 'package:atlas/screens/home/profile_page/following_page.dart';
import 'package:atlas/screens/home/profile_page/followers_page.dart';
import 'package:atlas/screens/home/profile_page/workout_page.dart';

class DefaultProfile extends StatefulWidget {
  final String username;

  const DefaultProfile({super.key, required this.username});

  @override
  State<DefaultProfile> createState() => _DefaultProfileState();
}

class _DefaultProfileState extends State<DefaultProfile> {
  Future<Map<String, dynamic>> userDataFuture =
      Future.value({}); // Initialize with an empty map
  String? userId; // Variable to store userId separately

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    // Fetch the userId
    String fetchedUserId = await DatabaseService().getUserID(widget.username);

    // Check if a valid userId was fetched
    if (fetchedUserId.isNotEmpty) {
      setState(() {
        userId = fetchedUserId; // Update the userId
        // Fetch the user data using the obtained userId and update userDataFuture
        userDataFuture = DatabaseService().getUserData(userId!);
      });
    } else {
      // Handle the case where no valid userId is fetched
      // This might involve setting some error state or showing a message
    }
  }

  Widget _buildCountButton(String label, Future<List<dynamic>>? countFuture) {
    if (countFuture == null) {
      return const CircularProgressIndicator();
    }

    return FutureBuilder<List<dynamic>>(
      future: countFuture,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the Future to complete
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle any errors that occur during fetching the data
          return Text('Error: ${snapshot.error}');
        } else {
          // Once the Future is complete, use the length of the list
          int count = snapshot.data?.length ?? 0;
          return ElevatedButton(
            //decrease space between buttons

            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () {
              if (label == 'Followers') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      // pass the list input to display on the corresponding page
                      builder: (context) =>
                          FollowersPage(followers: countFuture)),
                );
              } else if (label == 'Following') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      // pass the list input to display on the corresponding page
                      builder: (context) =>
                          FollowingPage(following: countFuture)),
                );
              } else if (label == 'Workouts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      // pass the list input to display on the corresponding page
                      builder: (context) => WorkoutPage(workouts: countFuture)),
                );
                // Navigate to the following page
              }
            },
            child: Column(
              children: [
                Text('$count', style: const TextStyle(fontSize: 20)),
                Text(label),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('User not found or error occurred'));
        }

        final userData = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const SizedBox(width: 40),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: ListView(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            "https://image-cdn.essentiallysports.com/wp-content/uploads/arnold-schwarzenegger-volume-workout-1110x788.jpg"), // Replace with user's profile picture
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15.0),
                        Text(
                          '${userData['firstName'] ?? "First"} ${userData['lastName'] ?? "Last"}',
                          style: const TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          '@${userData['username'] ?? "username"}',
                          style: const TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCountButton(
                        'Workouts',
                        userId != null
                            ? DatabaseService().getWorkoutsByUser(userId!)
                            : null),
                    _buildCountButton(
                        'Followers',
                        userId != null
                            ? DatabaseService().getFollowers(userId!)
                            : null),
                    _buildCountButton(
                        'Following',
                        userId != null
                            ? DatabaseService().getFollowing(userId!)
                            : null),
                  ],
                ),
                const SizedBox(height: 15.0),
                const Divider(color: Colors.black, thickness: 2),
                const SizedBox(height: 15.0),
              ]),
            ],
          ),
        );
      },
    );
  }
}
