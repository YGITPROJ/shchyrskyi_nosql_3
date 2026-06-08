import csv
import os

os.makedirs('import', exist_ok=True)

print("Конвертація файлів")

# 1 movies.dat: MovieID::Title::Genres
print("Конвертація movies.dat")
with open('movies.dat', encoding='latin-1') as f_in, \
     open('import/movies.csv', 'w', newline='', encoding='utf-8') as f_out:
    writer = csv.writer(f_out)
    writer.writerow(['movieId', 'title', 'genres'])
    for line in f_in:
        parts = line.strip().split('::')
        writer.writerow(parts)

# 2 ratings.dat: UserID::MovieID::Rating
print("Конвертація ratings.dat")
with open('ratings.dat', encoding='latin-1') as f_in, \
     open('import/ratings.csv', 'w', newline='', encoding='utf-8') as f_out:
    writer = csv.writer(f_out)
    writer.writerow(['userId', 'movieId', 'rating'])
    for line in f_in:
        parts = line.strip().split('::')
        writer.writerow(parts[:3])

# 3 users.dat: UserID::Gender::Age::Occupation::Zip
print("Конвертація users.dat")
with open('users.dat', encoding='latin-1') as f_in, \
     open('import/users.csv', 'w', newline='', encoding='utf-8') as f_out:
    writer = csv.writer(f_out)
    writer.writerow(['userId', 'gender', 'age', 'occupation'])
    for line in f_in:
        parts = line.strip().split('::')
        writer.writerow(parts[:4])

print("Конвертація успішно завершена, файли лежать в папці 'import/'")
