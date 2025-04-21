//HOW IS INFORMATION STORED

/scans/{scanID}
    - userID: "abc123"
    - timestamp: "2025-04-17T12:01:00Z"
    - videoURL: "https://..."
    - detectedIngredients: ["apple", "cheese"]

/users/{userID}
    - name: "Sabrina"
    - scanCount: 14

/ingredients/{ingredientID}
    - name: "apple"
    - image: "https://..."
    - shelfLife: "3 weeks"
