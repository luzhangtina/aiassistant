import json

def load_survey(template_name="default_survey"):
    with open(f"templates/{template_name}.json", "r") as file:
        return json.load(file)

def get_question_list(survey_data):
    return [{'number': item['number'], 'question': item['question']} for item in survey_data]

def get_survey_data(survey_data, number_of_question):
    return next(
        (item for item in survey_data if item['number'] == number_of_question),
        None  # Return None if the question number is not found
    )
