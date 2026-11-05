import '../models/internship.dart';
import '../utils/constants.dart';

/// Sample internships used to populate the app. In local/demo mode these are
/// loaded into the in-memory store so the app is useful the moment it starts;
/// in Firebase mode the same list can be pushed to Firestore once (see the
/// "Seed Firestore" action in the Profile screen).
class SeedData {
  SeedData._();

  static DateTime _daysAgo(int d) =>
      DateTime.now().subtract(Duration(days: d));

  static List<Internship> internships() => <Internship>[
        Internship(
          id: 'i1',
          title: 'Flutter Developer Intern',
          company: 'Nova Apps',
          location: 'Pune',
          workMode: WorkMode.hybrid,
          stipend: 15000,
          durationMonths: 6,
          description:
              'Build cross-platform features in our Flutter app, work with '
              'REST APIs and Firebase, and ship to Play Store & App Store.',
          requiredSkills: <String>['Flutter', 'Git', 'SQL'],
          domains: <String>['Mobile Development', 'Software Development'],
          careerTracks: <String>['Mobile App Developer', 'Software Engineer'],
          postedAt: _daysAgo(2),
        ),
        Internship(
          id: 'i2',
          title: 'Data Science Intern',
          company: 'InsightLabs',
          location: 'Bangalore',
          workMode: WorkMode.onsite,
          stipend: 25000,
          durationMonths: 3,
          description:
              'Clean and analyse datasets, build ML models, and present '
              'insights to product teams. Python and SQL used daily.',
          requiredSkills: <String>[
            'Python',
            'Machine Learning',
            'Data Analysis',
            'SQL',
          ],
          domains: <String>['Data Science', 'AI / ML'],
          careerTracks: <String>['Data Scientist', 'ML Engineer'],
          postedAt: _daysAgo(1),
        ),
        Internship(
          id: 'i3',
          title: 'Frontend Web Developer Intern',
          company: 'PixelForge',
          location: 'Remote',
          workMode: WorkMode.remote,
          stipend: 12000,
          durationMonths: 4,
          description:
              'Develop responsive interfaces in React, collaborate with '
              'designers, and integrate backend APIs.',
          requiredSkills: <String>['JavaScript', 'React', 'Git'],
          domains: <String>['Web Development', 'Software Development'],
          careerTracks: <String>['Web Developer', 'Software Engineer'],
          postedAt: _daysAgo(5),
        ),
        Internship(
          id: 'i4',
          title: 'UI/UX Design Intern',
          company: 'Studio Lumen',
          location: 'Mumbai',
          workMode: WorkMode.hybrid,
          stipend: 10000,
          durationMonths: 3,
          description:
              'Craft wireframes and prototypes in Figma, run usability '
              'reviews, and refine design systems.',
          requiredSkills: <String>['UI/UX Design', 'Figma', 'Communication'],
          domains: <String>['Design', 'Product Management'],
          careerTracks: <String>['UI/UX Designer', 'Product Manager'],
          postedAt: _daysAgo(3),
        ),
        Internship(
          id: 'i5',
          title: 'Backend Developer Intern',
          company: 'CloudNine Systems',
          location: 'Hyderabad',
          workMode: WorkMode.onsite,
          stipend: 20000,
          durationMonths: 6,
          description:
              'Design REST APIs with Node.js, work with SQL databases, and '
              'deploy services on AWS.',
          requiredSkills: <String>['Node.js', 'SQL', 'Cloud / AWS', 'Git'],
          domains: <String>['Software Development', 'Cloud'],
          careerTracks: <String>['Software Engineer', 'Cloud Engineer'],
          postedAt: _daysAgo(4),
        ),
        Internship(
          id: 'i6',
          title: 'Machine Learning Intern',
          company: 'DeepMind Labs',
          location: 'Remote',
          workMode: WorkMode.remote,
          stipend: 30000,
          durationMonths: 6,
          description:
              'Train and evaluate ML models, work with large datasets, and '
              'write clean, reproducible Python code.',
          requiredSkills: <String>[
            'Python',
            'Machine Learning',
            'Data Analysis',
          ],
          domains: <String>['AI / ML', 'Data Science'],
          careerTracks: <String>['ML Engineer', 'Data Scientist'],
          postedAt: _daysAgo(0),
        ),
        Internship(
          id: 'i7',
          title: 'Digital Marketing Intern',
          company: 'BrightReach',
          location: 'Delhi',
          workMode: WorkMode.hybrid,
          stipend: 8000,
          durationMonths: 3,
          description:
              'Run social campaigns, write content, and track performance '
              'with analytics tools.',
          requiredSkills: <String>[
            'Digital Marketing',
            'Content Writing',
            'Communication',
          ],
          domains: <String>['Marketing', 'Content'],
          careerTracks: <String>['Marketing Specialist'],
          postedAt: _daysAgo(6),
        ),
        Internship(
          id: 'i8',
          title: 'Android Developer Intern',
          company: 'Appsphere',
          location: 'Ahmedabad',
          workMode: WorkMode.onsite,
          stipend: 14000,
          durationMonths: 4,
          description:
              'Build native Android features in Java/Kotlin and integrate '
              'with backend services.',
          requiredSkills: <String>['Android', 'Java', 'Git'],
          domains: <String>['Mobile Development', 'Software Development'],
          careerTracks: <String>['Mobile App Developer', 'Software Engineer'],
          postedAt: _daysAgo(7),
        ),
        Internship(
          id: 'i9',
          title: 'Cybersecurity Intern',
          company: 'SecureEdge',
          location: 'Bangalore',
          workMode: WorkMode.onsite,
          stipend: 22000,
          durationMonths: 6,
          description:
              'Assist with vulnerability assessments, monitor threats, and '
              'document security findings.',
          requiredSkills: <String>['Cybersecurity', 'Python', 'Communication'],
          domains: <String>['Cybersecurity', 'Cloud'],
          careerTracks: <String>['Cybersecurity Analyst'],
          postedAt: _daysAgo(8),
        ),
        Internship(
          id: 'i10',
          title: 'Product Management Intern',
          company: 'LaunchPad',
          location: 'Remote',
          workMode: WorkMode.remote,
          stipend: 18000,
          durationMonths: 3,
          description:
              'Support product roadmap planning, write specs, and coordinate '
              'between design and engineering.',
          requiredSkills: <String>[
            'Communication',
            'Project Management',
            'Excel',
          ],
          domains: <String>['Product Management', 'Software Development'],
          careerTracks: <String>['Product Manager'],
          postedAt: _daysAgo(2),
        ),
      ];
}
