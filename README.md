# 🍽️ Restaurant Survey App

A **Flutter + Supabase** powered restaurant survey and review application.  
This app allows customers to browse the restaurant menu, rate dishes, and leave feedback. Admins can log in to view menu ratings, read reviews, and manage feedback in real-time.

---

## ✨ Features

### 👤 Customer Side

#### 📜 Onboarding & Authentication
- Splash & onboarding screens

#### 🍔 Menu & Reviews
- Browse menu items by category (**Main Course / Dessert**)  
- Toggle between **list view** and **grid view**  
- Multi-select dishes and submit reviews  
- Ratings with **Flutter Rating Bar**  
- Comment validation (positive/negative words handling)

#### 🌍 Internationalization
- Supports **English** 🇬🇧 and **Arabic** 🇪🇬  
- RTL layout for Arabic  
- Language toggle switcher  

#### 🎨 Theming
- Light / Dark mode toggle  
- Restaurant-inspired warm UI with terracotta, cream, and plum accents  

---

### 🛠️ Admin Side

#### 🔑 Admin Login
- Simple credential-based login (`admin / admin123` by default)

#### 📊 Menu Review Dashboard
- View menu items with **average ratings**  
- Sort by rating (**highest → lowest** or **lowest → highest**)  

#### 📝 Detailed Review Page
- View user-submitted comments & ratings per dish  
- Average rating indicator  
- Reviews sorted from **lowest rating upwards**

---

## 🧰 Tech Stack
- **Frontend:** Flutter (Dart)  
- **Backend:** Supabase (Postgres + Auth + Realtime API)  
- **State Management:** GetX  
- **Persistence:** SharedPreferences (for theme)  
- **Image Loading:** CachedNetworkImage  
- **Rating Widget:** flutter_rating_bar  

---

## 🗄️ Database Schema (Supabase)

### `menu` table
| Column       | Type     | Notes                          |
|--------------|----------|--------------------------------|
| menu_item_id | int4 (PK)| Auto-increment primary key      |
| meal_name    | varchar  | Name of the dish               |
| description  | text     | Description of the dish         |
| price        | numeric  | Price of the dish (EGP)         |
| category     | varchar  | e.g., `Main Course`, `Dessert` |
| image_url    | text     | Public URL for dish image       |

### `users` table
| Column    | Type     | Notes                       |
|-----------|----------|-----------------------------|
| user_id   | int4 (PK)| Auto-increment primary key   |
| user_name | varchar  | Name of the customer         |
| phone     | varchar  | Customer phone number        |

### `reviews` table
| Column       | Type       | Notes                                   |
|--------------|------------|-----------------------------------------|
| review_id    | int4 (PK)  | Auto-increment primary key              |
| user_id      | int4 (FK)  | References `users.user_id`              |
| menu_item_id | int4 (FK)  | References `menu.menu_item_id`          |
| rating       | numeric    | Rating given by the user (1–5)          |
| comment      | text       | Written feedback from the user          |
| created_at   | timestamptz| Auto timestamp of when review submitted |

---

### 🔗 Relationships
- 1 `menu` item → many `reviews`  
- 1 `user` → many `reviews`  
- `reviews.menu_item_id` → `menu.menu_item_id`  
- `reviews.user_id` → `users.user_id`  
