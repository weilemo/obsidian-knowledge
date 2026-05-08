#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct Student {
    int id;              
    char name[50];       
    float score;         
    struct Student* next; 
} Student;


Student* createStudent(int id, const char* name, float score) {
    Student* newStudent = (Student*)malloc(sizeof(Student));
    if (newStudent == NULL) {
        printf("内存分配失败\n");
        return NULL;
    }
    newStudent->id = id;
    strcpy(newStudent->name, name);
    newStudent->score = score;
    newStudent->next = NULL;
    return newStudent;
}


Student* loadFromFile(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (file == NULL) {
        printf("无法打开文件: %s\n", filename);
        return NULL;
    }

    Student* head = NULL;
    Student* tail = NULL;
    char line[256];
    

    while (fgets(line, sizeof(line), file) != NULL) {

        line[strcspn(line, "\n")] = 0;
        
        int id;
        char name[50];
        float score;
        
        if (sscanf(line, "%d,%49[^,],%f", &id, name, &score) == 3) {
            Student* newStudent = createStudent(id, name, score);
            if (newStudent == NULL) {
                fclose(file);
                return head;
            }
            
            if (head == NULL) {
                head = newStudent;
                tail = newStudent;
            } else {
                tail->next = newStudent;
                tail = newStudent;
            }
        } else {
            printf("警告: 跳过无效行: %s\n", line);
        }
    }
    
    fclose(file);
    printf("成功从文件 %s 加载学生数据\n", filename);
    return head;
}

void printStudents(Student* head) {
    if (head == NULL) {
        printf("学生列表为空\n");
        return;
    }
    
    printf("学号\t姓名\t\t\t成绩\n");
    printf("----\t----------------\t----\n");
    
    Student* current = head;
    while (current != NULL) {
        printf("%d\t%-16s\t%.2f\n", current->id, current->name, current->score);
        current = current->next;
    }
}

Student* copyList(Student* head) {
    if (head == NULL) return NULL;
    
    Student* newHead = NULL;
    Student* newTail = NULL;
    Student* current = head;
    
    while (current != NULL) {
        Student* newNode = createStudent(current->id, current->name, current->score);
        if (newNode == NULL) {
            return newHead;
        }
        
        if (newHead == NULL) {
            newHead = newNode;
            newTail = newNode;
        } else {
            newTail->next = newNode;
            newTail = newNode;
        }
        
        current = current->next;
    }
    
    return newHead;
}

void freeList(Student* head) {
    Student* current = head;
    while (current != NULL) {
        Student* next = current->next;
        free(current);
        current = next;
    }
}

Student* sortByScore(Student* head) {
    if (head == NULL || head->next == NULL) {
        return head;
    }
    
    Student* sorted = NULL;
    Student* current = head;
    
    while (current != NULL) {
        Student* next = current->next;
        
        if (sorted == NULL || current->score > sorted->score) {
            current->next = sorted;
            sorted = current;
        } else {
            Student* temp = sorted;
            while (temp->next != NULL && temp->next->score >= current->score) {
                temp = temp->next;
            }
            current->next = temp->next;
            temp->next = current;
        }
        
        current = next;
    }
    
    return sorted;
}

Student* sortByName(Student* head) {
    if (head == NULL || head->next == NULL) {
        return head;
    }
    
    Student* sorted = NULL;
    Student* current = head;
    
    while (current != NULL) {
        Student* next = current->next;
        
        if (sorted == NULL || strcmp(current->name, sorted->name) < 0) {
            current->next = sorted;
            sorted = current;
        } else {
            Student* temp = sorted;
            while (temp->next != NULL && strcmp(temp->next->name, current->name) < 0) {
                temp = temp->next;
            }
            current->next = temp->next;
            temp->next = current;
        }
        
        current = next;
    }
    
    return sorted;
}

void saveToFile(Student* head, const char* filename) {
    FILE* file = fopen(filename, "w");
    if (file == NULL) {
        printf("无法创建文件: %s\n", filename);
        return;
    }
    
    Student* current = head;
    while (current != NULL) {
        fprintf(file, "%d,%s,%.2f\n", current->id, current->name, current->score);
        current = current->next;
    }
    
    fclose(file);
    printf("数据已保存到文件: %s\n", filename);
}


float calculateAverage(Student* head) {
    if (head == NULL) {
        return 0.0;
    }
    
    float sum = 0.0;
    int count = 0;
    Student* current = head;
    
    while (current != NULL) {
        sum += current->score;
        count++;
        current = current->next;
    }
    
    return sum / count;
}


Student* findTopStudents(Student* head, int count) {
    if (head == NULL || count <= 0) {
        return NULL;
    }
    
    Student* sorted = sortByScore(copyList(head));
    Student* topHead = NULL;
    Student* topTail = NULL;
    Student* current = sorted;
    int i = 0;
    
    while (current != NULL && i < count) {
        Student* newStudent = createStudent(current->id, current->name, current->score);
        if (newStudent == NULL) {
            break;
        }
        
        if (topHead == NULL) {
            topHead = newStudent;
            topTail = newStudent;
        } else {
            topTail->next = newStudent;
            topTail = newStudent;
        }
        
        current = current->next;
        i++;
    }
    
    freeList(sorted); 
    return topHead;
}

int main() {
    printf("=== 学生成绩管理系统 ===\n\n");
    Student* originalList = loadFromFile("students.txt");
    
    if (originalList == NULL) {
        printf("无法加载数据，程序退出\n");
        return 1;
    }
    
    printf("\n1. 原始学生数据:\n");
    printStudents(originalList);
    
    printf("\n2. 按成绩排序结果:\n");
    Student* scoreSorted = sortByScore(copyList(originalList));
    printStudents(scoreSorted);
    
    printf("\n3. 按姓名排序结果:\n");
    Student* nameSorted = sortByName(copyList(originalList));
    printStudents(nameSorted);
    
    printf("\n4. 统计信息:\n");
    float avg = calculateAverage(originalList);
    printf("平均分: %.2f\n", avg);
    
    printf("\n5. 前5名学生:\n");
    Student* topStudents = findTopStudents(originalList, 5);
    printStudents(topStudents);
    
    printf("\n6. 保存结果到文件:\n");
    saveToFile(scoreSorted, "sorted_students.txt");
    
    freeList(originalList);
    freeList(scoreSorted);
    freeList(nameSorted);
    freeList(topStudents);
    
    printf("\n程序执行完毕!\n");
    return 0;
}