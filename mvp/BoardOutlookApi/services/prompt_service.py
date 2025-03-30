def create_system_prompt(init, summary, client_name, question_text, description, chat_history, magic_ending_word):
    if not summary:
        role_prompt = f"You are a professional consultant guiding user {client_name} through a 3 minutes conversation. The conversation revolves around the main topic of {question_text}."
        question_prompt = f"Please greet user {client_name} first, then ask the main question: {question_text}"
        goal_prompt = f"The insight you need to gather from the main topic is to {description}."
        rule_prompt = f"""
            When responding to the user's answer, please follow these rules strictly:
            1. Based on the user's response, please reply with one of the following:
               - If the conversation has covered all the insights you need to gather, end the conversion and reply with "{magic_ending_word}". 
               - If the user refuses to answer a question or insists on ending the conversation, end the conversion and reply with "{magic_ending_word}". 
               - If the user repeats the answer frequently, end the conversion and reply with "{magic_ending_word}". 
               - If the user's response is not related to the topic of the conversation, gently guide {client_name} back to the topic.
            
            2. Keep your tone friendly, professional, and conversational, encouraging thoughtful and complete responses.

            3. Your response ***MUST*** be concise and contain ***ONLY ONE*** question for the user to answer.

            4. Keep your conversion within ***5 rounds*** no matter if enought insights is collected or not. When ending the conversion, reply with "{magic_ending_word}".
        """
        if not init:
            question_prompt = f"Do not greet user, please start directly by asking user the main question: {question_text}"

        system_prompt = f"""
            {role_prompt}
            {question_prompt}
            {goal_prompt}
            {rule_prompt}
        """
    else:
        system_prompt = f"""
            Your role is to summarize the completed conversation which user {client_name} provided. 
            
            Provide a concise summary of the responses and thank {client_name} for taking the time and having the conversion. 

            Do not ask any question in your response!
        """
    
    return system_prompt
