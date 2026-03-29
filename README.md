# Spending-saver

# Snowflake + AI Integration

This project uses Snowflake as both the data platform and AI inference layer.
We store structured user spending data in Snowflake and use Snowflake Cortex to classify items as essential or non-essential directly within our backend pipeline.

Instead of relying on external AI APIs, we intentionally integrated Cortex through SQL (SNOWFLAKE.CORTEX.COMPLETE) so that both data and AI processing remain within the same system.

This allows our application to:

Reduce external dependencies
Keep data and AI tightly coupled
Scale naturally with stored financial data

We initially experimented with other LLM providers, but chose Snowflake Cortex to align with a data-centric AI architecture.
