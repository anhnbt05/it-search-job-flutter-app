import 'package:flutter/material.dart';

class FindJobsView extends StatelessWidget {
  const FindJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final job = {
      "id": "c1f917bf-f4ab-434a-a446-d4dfded60687",
      "title": "Thực tập sinh Web Developer",
      "description":
      "Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn",
      "address": "Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam",
      "salary": "Hỗ trợ 3,000,000 - 5,000,000 VND/tháng",
      "vacancies": 3,
      "type": "part_time",
      "workingTimes": "Thứ 2 - Thứ 6, 8:30 - 17:30",
      "status": "open",
      "level": "intern",
      "company": {
        "name": "Công ty ABC",
        "websiteUrl": "https://techcorp.com",
        "description": "Công ty đứng đầu về công nghệ tại Việt Nam",
      },
      "recruiter": {
        "fullName": "Lê Văn Nam",
        "position": "Trưởng phòng nhân sự"
      },
      "categories": ["Back End"]
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          JobCard(job: job),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final company = job['company'];
    final recruiter = job['recruiter'];
    final categories = job['categories'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            company['name'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.place, job['address']),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.monetization_on, job['salary']),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time, job['workingTimes']),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.category, categories.join(', ')),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) => _buildTag(cat)).toList(),
          ),
          const Divider(height: 24, color: Color(0xFFE5E7EB)),
          Text(
            job['description'],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(
                '${recruiter['fullName']} - ${recruiter['position']}',
                style: const TextStyle(color: Color(0xFF4B5563)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Xem chi tiết',
                    style: TextStyle(color: Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                  label: const Text('Nộp đơn ứng tuyển'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.blue[900],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
      ),
    );
  }
}
