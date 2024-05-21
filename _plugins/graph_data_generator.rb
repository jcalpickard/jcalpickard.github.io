# _plugins/graph_data_generator.rb

require 'json'
require 'fileutils'

module Jekyll
  class GraphDataGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      compost_notes = site.collections['compost'].docs
      nodes = []
      links = []

      compost_notes.each do |note|
        node = {
          id: note.data['title'],
          label: note.data['title'],
          stage: note.data['stage'],
          tags: note.data['tags'],
          url: note.url
        }
        nodes << node

        if note.data['backlinks']
          note.data['backlinks'].each do |backlink|
            target_doc = site.documents.find { |d| d.url == backlink['url'] }
            if target_doc
              links << {
                source: note.data['title'],
                target: target_doc.data['title']
              }
            else
              Jekyll.logger.warn "Backlink missing title for note: #{note.data['title']}"
            end
          end
        else
          Jekyll.logger.warn "No backlinks found for note: #{note.data['title']}"
        end
      end

      graph_data = { nodes: nodes, links: links }
      site.config['graph_data'] = graph_data
    end
  end

  class GraphDataWriter < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      graph_data = site.config['graph_data']
      output_path = File.join(site.dest, 'assets', 'graph-data.json')
      
      # Ensure the directory exists
      FileUtils.mkdir_p(File.dirname(output_path))
      
      # Write the JSON data to the file
      File.write(output_path, JSON.pretty_generate(graph_data))
      
      # Confirm the file was written
      if File.exist?(output_path)
        Jekyll.logger.info "Graph data successfully written to #{output_path}"
      else
        Jekyll.logger.error "Failed to write graph data to #{output_path}"
      end
    end
  end
end