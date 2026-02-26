class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  // Helper to get strings
  String get(String key) {
    if (locale == 'en') {
      return _en[key] ?? key;
    }
    return _id[key] ?? key;
  }

  // Indonesian Dictionary (Default)
  static const Map<String, String> _id = {
    // Navigation
    'nav_dashboard': 'Dasbor',
    'nav_tasks': 'Tugas',
    'nav_rpg': 'RPG',
    'nav_stats': 'Statistik',
    'nav_notes': 'Catatan',

    // Dashboard
    'dash_greeting': 'Siap Level Up hari ini?',
    'dash_xp_progress': 'Bilah Pengalaman',
    'dash_today_tasks': 'Tugas Hari Ini',
    'dash_empty_tasks':
        'Belum ada misi hari ini!\nTekan tombol + untuk memulai.',
    'dash_recent_notes': 'Catatan Terbaru',
    'dash_view_all': 'Lihat Semua',

    // Tasks
    'task_add_new': 'Tambah Tugas',
    'task_title': 'Panggil Misi Apa?',
    'task_desc': 'Detail atau langkah pengerjaan...',
    'task_difficulty': 'Tingkat Kesulitan',
    'task_difficulty_easy': 'Gampang',
    'task_difficulty_medium': 'Sedang',
    'task_difficulty_hard': 'Sulit',
    'task_stat_type': 'Tipe Atribut',
    'task_stat_int': 'Kecerdasan',
    'task_stat_disc': 'Kedisiplinan',
    'task_stat_hp': 'Kesehatan',
    'task_stat_wlth': 'Kekayaan',
    'task_quadrant': 'Prioritas Eisenhower',
    'task_quad_1': 'Mendesak & Penting (Lakukan)',
    'task_quad_2': 'Penting (Jadwalkan)',
    'task_quad_3': 'Mendesak (Delegasikan)',
    'task_quad_4': 'Tidak Penting (Hindari)',
    'task_save': 'Simpan Tugas',
    'task_tab_active': 'Berjalan',
    'task_tab_completed': 'Selesai',

    // RPG - General
    'rpg_title': 'Perjalanan RPG',
    'rpg_tab_quests': 'Misi',
    'rpg_tab_badges': 'Pencapaian',
    'rpg_tab_skills': 'Skill',
    'rpg_sp_label': 'Poin Skill',

    // RPG - Quests
    'quest_empty':
        'Tidak ada Misi Spesial saat ini.\nSelesaikan tugas biasa untuk memicunya!',
    'quest_expires': 'Berakhir:',

    // RPG - Achievements
    'badge_achieved': 'Didapatkan',

    // RPG - Skills
    'skill_cost': 'Harga:',
    'skill_unlock': 'Buka',
    'skill_upgrade': 'Tingkatkan',
    'skill_maxed': 'Maksimal',
    'skill_error_sp':
        'Poin Skill (SP) tidak cukup atau ada syarat yang belum terpenuhi!',
    'skill_req_not_met': 'Poin Skill belum cukup atau syarat tidak terpenuhi!',

    // Stats
    'stats_title': 'Analisis & Statistik',
    'stats_level': 'Level',
    'stats_total_xp': 'Total EXP',
    'stats_done': 'Selesai',
    'stats_todo': 'Sisa',
    'stats_current_level': 'Level Saat Ini',
    'stats_streak': 'Hari Beruntun',
    'stats_ai_insights': 'Wawasan Cerdas',
    'stats_heatmap': 'Peta Produktivitas (90 Hari)',
    'stats_charts': 'Grafik Performa',
    'stats_rpg_progress': 'Kemajuan Atribut RPG',
    'stats_burnout_warn':
        'Awas Burnout! Banyak tugas berat akhir-akhir ini. Yuk istirahat sejenak.',
    'stats_burnout_ok':
        'Bagus! Ritme kerjamu seimbang dan aman dari kelelahan mental.',
    'stats_insight': 'Wawasan AI',
    'stats_rpg': 'Kemajuan Status RPG',
    'insight_prod_time': 'Waktu Paling Produktif',
    'insight_prod_time_desc': 'Berdasarkan jam selesai tugas',
    'insight_best_day': 'Hari Terbaik',
    'insight_best_day_desc': 'Hari dengan tugas selesai terbanyak',
    'insight_avg_time': 'Rata-rata Waktu Selesai',
    'insight_avg_time_desc': 'Dari dibuat hingga selesai',
    'insight_burnout': 'Risiko Burnout',
    'insight_burnout_val': 'Beban Tinggi Terdeteksi',
    'insight_burnout_desc': 'Ayo istirahat! >25 tugas',
    'insight_pace': 'Kecepatan',
    'insight_pace_val': 'Sehat',
    'insight_pace_desc': 'Beban kerja seimbang',
    'time_d': 'h',
    'time_h': 'j',
    'time_m': 'm',
    'chart_xp': 'Tren Pertumbuhan XP (7 Hari)',
    'chart_xp_desc': 'Total XP didapat 7 hari terakhir',
    'chart_tasks': 'Tugas Selesai',
    'chart_quadrant': 'Fokus Kuadran',
    'heatmap_less': 'Sedikit',
    'heatmap_more': 'Banyak',
    'cal_mon': 'Sen',
    'cal_tue': 'Sel',
    'cal_wed': 'Rab',
    'cal_thu': 'Kam',
    'cal_fri': 'Jum',
    'cal_sat': 'Sab',
    'cal_sun': 'Min',

    // Settings & Misc
    'settings_title': 'Pengaturan',
    'settings_language': 'Bahasa / Language',
    'settings_dark_mode': 'Mode Gelap',
    'settings_theme': 'Warna Tema',
  };

  // English Dictionary
  static const Map<String, String> _en = {
    // Navigation
    'nav_dashboard': 'Dashboard',
    'nav_tasks': 'Tasks',
    'nav_rpg': 'RPG',
    'nav_stats': 'Stats',
    'nav_notes': 'Notes',

    // Dashboard
    'dash_greeting': 'Ready to Level Up today?',
    'dash_xp_progress': 'Experience Bar',
    'dash_today_tasks': 'Today\'s Quests',
    'dash_empty_tasks': 'No missions today!\nTap the + button to start.',
    'dash_recent_notes': 'Recent Notes',
    'dash_view_all': 'View All',

    // Tasks
    'task_add_new': 'Add New Task',
    'task_title': 'Mission Title',
    'task_desc': 'Details or steps...',
    'task_difficulty': 'Difficulty',
    'task_difficulty_easy': 'Easy',
    'task_difficulty_medium': 'Medium',
    'task_difficulty_hard': 'Hard',
    'task_stat_type': 'Attribute Type',
    'task_stat_int': 'Intelligence',
    'task_stat_disc': 'Discipline',
    'task_stat_hp': 'Health',
    'task_stat_wlth': 'Wealth',
    'task_quadrant': 'Priority (Eisenhower)',
    'task_quad_1': 'Urgent & Important (Do)',
    'task_quad_2': 'Important (Schedule)',
    'task_quad_3': 'Urgent (Delegate)',
    'task_quad_4': 'Not Important (Drop)',
    'task_save': 'Save Task',
    'task_tab_active': 'Active',
    'task_tab_completed': 'Completed',

    // RPG - General
    'rpg_title': 'RPG Journey',
    'rpg_tab_quests': 'Quests',
    'rpg_tab_badges': 'Badges',
    'rpg_tab_skills': 'Skills',
    'rpg_sp_label': 'Skill Points',

    // RPG - Quests
    'quest_empty':
        'No active quests right now.\nComplete regular tasks to trigger new ones!',
    'quest_expires': 'Expires:',

    // RPG - Achievements
    'badge_achieved': 'Achieved',

    // RPG - Skills
    'skill_cost': 'Cost:',
    'skill_unlock': 'Unlock',
    'skill_upgrade': 'Upgrade',
    'skill_maxed': 'Max',
    'skill_error_sp': 'Not enough Skill Points or missing requirements!',
    'skill_req_not_met': 'Not enough Skill Points or missing requirements!',

    // Stats
    'stats_title': 'Analytics & Stats',
    'stats_level': 'Level',
    'stats_total_xp': 'Total XP',
    'stats_done': 'Done',
    'stats_todo': 'To Do',
    'stats_current_level': 'Current Level',
    'stats_streak': 'Day Streak',
    'stats_ai_insights': 'Smart Insights',
    'stats_heatmap': 'Productivity Map (90 Days)',
    'stats_charts': 'Performance Charts',
    'stats_rpg_progress': 'RPG Attributes Progress',
    'stats_burnout_warn':
        'Burnout Warning! High volume of hard tasks recently. Take a break.',
    'stats_burnout_ok': 'Great pace! Your workload is balanced and healthy.',
    'stats_insight': 'AI Productivity Insights',
    'stats_rpg': 'RPG Stats Progress',
    'insight_prod_time': 'Most Productive Time',
    'insight_prod_time_desc': 'Based on completion hours',
    'insight_best_day': 'Best Day',
    'insight_best_day_desc': 'Day with most completions',
    'insight_avg_time': 'Avg. Completion Time',
    'insight_avg_time_desc': 'From creation to done',
    'insight_burnout': 'Burnout Risk',
    'insight_burnout_val': 'High Load Detected',
    'insight_burnout_desc': 'Take a break! >25 tasks',
    'insight_pace': 'Pace',
    'insight_pace_val': 'Healthy',
    'insight_pace_desc': 'Sustainable workload',
    'time_d': 'd',
    'time_h': 'h',
    'time_m': 'm',
    'chart_xp': 'XP Growth Trend (7 Days)',
    'chart_xp_desc': 'Total XP gained over the last week',
    'chart_tasks': 'Tasks Done',
    'chart_quadrant': 'Quadrant Focus',
    'heatmap_less': 'Less',
    'heatmap_more': 'More',
    'cal_mon': 'Mon',
    'cal_tue': 'Tue',
    'cal_wed': 'Wed',
    'cal_thu': 'Thu',
    'cal_fri': 'Fri',
    'cal_sat': 'Sat',
    'cal_sun': 'Sun',

    // Settings & Misc
    'settings_title': 'Settings',
    'settings_language': 'Language / Bahasa',
    'settings_dark_mode': 'Dark Mode',
    'settings_theme': 'Theme Color',
  };
}
