#include <stdio.h>
#include <stdlib.h>
#include <math.h>


typedef struct Term {
    float coeff;       
    int exp;          
    struct Term* next; 
} Term;

Term* createTerm(float coeff, int exp) {
    Term* newTerm = (Term*)malloc(sizeof(Term));
    if (newTerm == NULL) {
        printf("内存分配失败\n");
        exit(1);
    }
    newTerm->coeff = coeff;
    newTerm->exp = exp;
    newTerm->next = NULL;
    return newTerm;
}

void insertTerm(Term** poly, float coeff, int exp) {
    Term* newTerm = createTerm(coeff, exp);
    
    if (*poly == NULL || (*poly)->exp < exp) {
        newTerm->next = *poly;
        *poly = newTerm;
    } else {
        Term* current = *poly;
        while (current->next != NULL && current->next->exp > exp) {
            current = current->next;
        }
        
        if (current->exp == exp) {
            current->coeff += coeff;
            free(newTerm);
        } else {
            newTerm->next = current->next;
            current->next = newTerm;
        }
    }
}

Term* simplifyPolynomial(Term* poly) {
    if (poly == NULL) return NULL;
    
    Term* result = NULL;
    Term* current = poly;
    
    while (current != NULL) {
        insertTerm(&result, current->coeff, current->exp);
        current = current->next;
    }
    
    Term* prev = NULL;
    current = result;
    while (current != NULL) {
        if (fabs(current->coeff) < 1e-6) {
            if (prev == NULL) {
                result = current->next;
                free(current);
                current = result;
            } else {
                prev->next = current->next;
                free(current);
                current = prev->next;
            }
        } else {
            prev = current;
            current = current->next;
        }
    }
    
    return result;
}

Term* addPolynomials(Term* poly1, Term* poly2) {
    Term* result = NULL;
    
    Term* temp = poly1;
    while (temp != NULL) {
        insertTerm(&result, temp->coeff, temp->exp);
        temp = temp->next;
    }
    
    temp = poly2;
    while (temp != NULL) {
        insertTerm(&result, temp->coeff, temp->exp);
        temp = temp->next;
    }
    
    return simplifyPolynomial(result);
}

Term* multiplyPolynomials(Term* poly1, Term* poly2) {
    if (poly1 == NULL || poly2 == NULL) return NULL;
    
    Term* result = NULL;
    
    Term* temp1 = poly1;
    while (temp1 != NULL) {
        Term* temp2 = poly2;
        while (temp2 != NULL) {
            float coeff = temp1->coeff * temp2->coeff;
            int exp = temp1->exp + temp2->exp;
            insertTerm(&result, coeff, exp);
            temp2 = temp2->next;
        }
        temp1 = temp1->next;
    }
    
    return simplifyPolynomial(result);
}

float evaluatePolynomial(Term* poly, float x) {
    float result = 0.0;
    Term* current = poly;
    
    while (current != NULL) {
        result += current->coeff * pow(x, current->exp);
        current = current->next;
    }
    
    return result;
}

void printPolynomial(Term* poly) {
    if (poly == NULL) {
        printf("0.00");
        return;
    }
    
    Term* current = poly;
    int firstTerm = 1;
    
    while (current != NULL) {
        if (!firstTerm && current->coeff >= 0) {
            printf(" + ");
        }
        
        if (current->exp == 0) {
            printf("%.2f", current->coeff);
        } else if (current->exp == 1) {
            printf("%.2fx", current->coeff);
        } else {
            printf("%.2fx^%d", current->coeff, current->exp);
        }
        
        firstTerm = 0;
        current = current->next;
    }
}

void freePolynomial(Term* poly) {
    Term* current = poly;
    while (current != NULL) {
        Term* next = current->next;
        free(current);
        current = next;
    }
}

Term* createTestPolynomial1() {
    Term* poly = NULL;
    insertTerm(&poly, 3.0, 3);
    insertTerm(&poly, 2.0, 2);
    insertTerm(&poly, 5.0, 1);
    insertTerm(&poly, 1.0, 0);
    return poly;
}

Term* createTestPolynomial2() {
    Term* poly = NULL;
    insertTerm(&poly, 2.0, 2);
    insertTerm(&poly, 4.0, 1);
    insertTerm(&poly, 3.0, 0);
    return poly;
}

int main() {
    Term* poly1 = createTestPolynomial1();
    Term* poly2 = createTestPolynomial2();
    
    printf("多项式1: ");
    printPolynomial(poly1);
    printf("\n");
    
    printf("多项式2: ");
    printPolynomial(poly2);
    printf("\n");
    
    Term* sum = addPolynomials(poly1, poly2);
    printf("多项式1 + 多项式2: ");
    printPolynomial(sum);
    printf("\n");
    
    Term* product = multiplyPolynomials(poly1, poly2);
    printf("多项式1 × 多项式2: ");
    printPolynomial(product);
    printf("\n");
    
    float x = 2.0;
    float value = evaluatePolynomial(poly1, x);
    printf("多项式1在x=%.2f时的值: %.2f\n", x, value);
    
    freePolynomial(poly1);
    freePolynomial(poly2);
    freePolynomial(sum);
    freePolynomial(product);
    
    return 0;
}